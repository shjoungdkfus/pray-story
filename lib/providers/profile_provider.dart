import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import 'auth_provider.dart';

final profileProvider = FutureProvider.autoDispose<ProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final supabase = ref.watch(supabaseProvider);
  final res = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (res == null) return null;
  return ProfileModel.fromJson(res, user.email ?? '');
});
