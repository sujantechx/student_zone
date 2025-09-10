import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_zone/presentation/screens/student/pdf_list_screen.dart';
import 'package:student_zone/presentation/screens/student/subject_pdf.dart';
import 'dart:developer' as developer;
import '../../data/models/chapter_model.dart';
import '../../data/models/subject_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/manage_chapters_screen.dart';
import '../../presentation/screens/admin/manage_content_screen.dart';
import '../../presentation/screens/admin/manage_students_screen.dart';
import '../../presentation/screens/auth/approval_pending_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/student_dashboard_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/student/chapter_pdf.dart';
import '../../presentation/screens/student/chapters_list_screen.dart';
import '../../presentation/screens/student/pdf_vewer_screen.dart';
import '../../presentation/screens/student/subjects_list_screen.dart';
import '../../presentation/screens/student/video_list_screen.dart';
import '../../presentation/widgets/video_player_widget.dart';
import 'app_routes.dart';

class AppRouter {
  final AuthCubit authCubit;
  late final GoRouter router;

  AppRouter({required this.authCubit}) {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
        GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
        GoRoute(path: AppRoutes.pendingApproval, builder: (context, state) => const PendingApprovalScreen()),
        GoRoute(path: AppRoutes.adminDashboard, builder: (context, state) => const AdminDashboardScreen()),
        GoRoute(path: AppRoutes.manageStudents, builder: (context, state) => const ManageStudentsScreen()),
        GoRoute(path: AppRoutes.manageContent, builder: (context, state) => const ManageContentScreen()),
        GoRoute(
          path: AppRoutes.manageChapters,
          builder: (context, state) {
            final subject = state.extra as SubjectModel;
            return ManageChaptersScreen(subject: subject);
          },
        ),
        GoRoute(
          path: AppRoutes.chaptersList,
          builder: (context, state) {
            final subject = state.extra as SubjectModel;
            return ChaptersListScreen(subject: subject);
          },
        ), GoRoute(
          path: AppRoutes.chapterPDF,
          builder: (context, state) {
            final subject = state.extra as SubjectModel;
            return ChapterPdf(subject: subject);
          },
        ),
        GoRoute(
          path: AppRoutes.pdfList,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            final subject = data['subject'] as SubjectModel;
            final chapter = data['chapter'] as ChapterModel;
            return PdfListScreen(subject: subject, chapter: chapter);
          },
        ),
        GoRoute(path: AppRoutes.pdfViewer, builder: (context, state){
          final url = state.pathParameters['url']!;
          return PdfViewerScreen(url: url);
        }),
        GoRoute(
          path: AppRoutes.videosList,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            final subject = data['subject'] as SubjectModel;
            final chapter = data['chapter'] as ChapterModel;
            return VideosListScreen(subject: subject, chapter: chapter);
          },
        ),
        GoRoute(
          path: '${AppRoutes.videoPlayer}/:videoId',
          builder: (context, state) {
            final videoId = state.pathParameters['videoId']!;
            return VideoPlayerScreen(videoId: videoId);
          },
        ),
        GoRoute(
          path: '${AppRoutes.pdfViewer}/:url',
          builder: (context, state) {
            final url = state.pathParameters['url']!;
            return PdfViewerScreen(url: url); // Added route for PdfViewerScreen
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return DashboardShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: AppRoutes.subjectsList, builder: (context, state) => const SubjectsListScreen()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: AppRoutes.subjectPDF, builder: (context, state) => const SubjectPdf()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),
              ],
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final authState = authCubit.state;
        final currentLocation = state.matchedLocation;
        developer.log('Redirect check: authState=$authState, currentLocation=$currentLocation');

        // Handle initial/loading states
        if (authState is AuthInitial || (authState is AuthLoading && currentLocation != AppRoutes.login && currentLocation != AppRoutes.register)) {
          developer.log('Redirecting to splash due to AuthInitial or AuthLoading (not on login/register)');
          return AppRoutes.splash;
        }

        // Handle authenticated state
        if (authState is Authenticated) {
          final user = authState.userModel;
          developer.log('Authenticated user: role=${user.role}, status=${user.status}, uid=${user.uid}');

          if (user.role == 'admin') {
            final isTryingToAccessStudentShell =
                currentLocation.startsWith(AppRoutes.subjectsList) ||
                    currentLocation.startsWith(AppRoutes.subjectPDF) ||
                    currentLocation.startsWith(AppRoutes.profile) ||
                    currentLocation.startsWith(AppRoutes.chaptersList) ||
                    currentLocation.startsWith(AppRoutes.videosList) ||
                    currentLocation.startsWith(AppRoutes.videoPlayer) ||
                    currentLocation.startsWith(AppRoutes.subjectPDF); // Added notes to admin restrictions
            final isOnAuthRoute = currentLocation == AppRoutes.login ||
                currentLocation == AppRoutes.register ||
                currentLocation == AppRoutes.splash ||
                currentLocation == AppRoutes.pendingApproval;

            if (isTryingToAccessStudentShell || isOnAuthRoute) {
              developer.log('Redirecting admin to adminDashboard');
              return AppRoutes.adminDashboard;
            }
          } else {
            final isTryingToAccessAdminRoute =
                currentLocation.startsWith(AppRoutes.adminDashboard) ||
                    currentLocation.startsWith(AppRoutes.manageStudents) ||
                    currentLocation.startsWith(AppRoutes.manageContent) ||
                    currentLocation.startsWith(AppRoutes.manageChapters);

            if (isTryingToAccessAdminRoute) {
              developer.log('Redirecting student to subjectsList');
              return AppRoutes.subjectsList;
            }

            if (user.status == 'approved' || user.status == 'approve') {
              if (currentLocation == AppRoutes.login ||
                  currentLocation == AppRoutes.register ||
                  currentLocation == AppRoutes.splash ||
                  currentLocation == AppRoutes.pendingApproval) {
                developer.log('Redirecting approved student to subjectsList');
                return AppRoutes.subjectsList;
              }
            } else {
              if (currentLocation != AppRoutes.pendingApproval) {
                developer.log('Redirecting unapproved student to pendingApproval');
                return AppRoutes.pendingApproval;
              }
            }
          }
        } else if (authState is Unauthenticated) {
          // Handle unauthenticated state
          if (authState.pendingApproval) {
            if (currentLocation != AppRoutes.pendingApproval) {
              developer.log('Redirecting to pendingApproval after registration');
              return AppRoutes.pendingApproval;
            }
          } else {
            final isAuthRoute = currentLocation == AppRoutes.login ||
                currentLocation == AppRoutes.register ||
                currentLocation == AppRoutes.splash;
            if (!isAuthRoute) {
              developer.log('Redirecting unauthenticated user to login');
              return AppRoutes.login;
            }
          }
        } else if (authState is AuthError) {
          // Handle AuthError for registration or unapproved accounts
          if (authState.message.contains('Registration successful') || authState.message.contains('Account not approved')) {
            if (currentLocation != AppRoutes.pendingApproval) {
              developer.log('Redirecting to pendingApproval due to registration or unapproved account');
              return AppRoutes.pendingApproval;
            }
          } else {
            developer.log('AuthError state: ${authState.message}, staying on current route');
            return null;
          }
        }

        developer.log('No redirect needed');
        return null;
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((event) {
      developer.log('AuthCubit stream event: $event');
      notifyListeners();
    });
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

