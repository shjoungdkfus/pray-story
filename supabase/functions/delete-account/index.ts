// 계정 완전 삭제 Edge Function
// Supabase 대시보드 > Edge Functions 에서 이 파일 내용을 붙여넣어 배포하세요.
// (또는 CLI: supabase functions deploy delete-account)
//
// 호출자 본인의 프로필/기도 기록/피드백을 지우고, auth.users 에서도 완전히 삭제한다.
// community_groups/group_members/community_letters/group_notices/letter_prayers 는
// auth.users(id) 에 ON DELETE CASCADE 로 걸려 있어 admin.deleteUser 호출 시 자동 삭제된다.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "missing authorization header" }), { status: 401 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // 호출자 신원 확인 (본인 JWT 기준)
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userErr } = await callerClient.auth.getUser();
  if (userErr || !userData?.user) {
    return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401 });
  }
  const userId = userData.user.id;

  // 실제 삭제는 service role 로만 수행
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  // 본인이 방장인 모임 중, 다른 멤버가 남아있는 모임은 소유권을 이전한다.
  // (그대로 두면 owner_id FK의 ON DELETE CASCADE 로 모임 전체 + 다른 멤버의 데이터까지 삭제됨)
  const { data: ownedGroups } = await adminClient
    .from("community_groups")
    .select("id")
    .eq("owner_id", userId);

  for (const group of ownedGroups ?? []) {
    const { data: otherMembers } = await adminClient
      .from("group_members")
      .select("user_id, joined_at")
      .eq("group_id", group.id)
      .neq("user_id", userId)
      .order("joined_at", { ascending: true })
      .limit(1);

    const successor = otherMembers?.[0];
    if (successor) {
      await adminClient
        .from("community_groups")
        .update({ owner_id: successor.user_id })
        .eq("id", group.id);
      await adminClient
        .from("group_members")
        .update({ role: "owner" })
        .eq("group_id", group.id)
        .eq("user_id", successor.user_id);
    }
    // 다른 멤버가 없으면 그대로 두어 계정 삭제 시 모임까지 함께 정리되게 한다.
  }

  await adminClient.from("prayers").delete().eq("user_id", userId);
  await adminClient.from("feedback").delete().eq("user_id", userId);
  await adminClient.from("profiles").delete().eq("id", userId);

  const { error: delErr } = await adminClient.auth.admin.deleteUser(userId);
  if (delErr) {
    return new Response(JSON.stringify({ error: delErr.message }), { status: 500 });
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
