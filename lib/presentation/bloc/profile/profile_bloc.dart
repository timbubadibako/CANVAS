import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/user_profile.dart';
import '../../../domain/repositories/profile_repository.dart';

// --- Events ---
abstract class ProfileEvent {}
class LoadProfileRequested extends ProfileEvent {
  final String userId;
  LoadProfileRequested(this.userId);
}
class UpdateProfileRequested extends ProfileEvent {
  final UserProfile profile;
  UpdateProfileRequested(this.profile);
}
class UpdateAvatarRequested extends ProfileEvent {
  final String userId;
  final String filePath;
  UpdateAvatarRequested(this.userId, this.filePath);
}

// --- States ---
abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  ProfileLoaded(this.profile);
}
class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}

// --- BLoC ---
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(ProfileInitial()) {
    on<LoadProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await _profileRepository.getProfile(event.userId);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<UpdateProfileRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        await _profileRepository.updateProfile(event.profile);
        emit(ProfileLoaded(event.profile));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<UpdateAvatarRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        await _profileRepository.updateAvatar(event.userId, event.filePath);
        final profile = await _profileRepository.getProfile(event.userId);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });
  }
}
