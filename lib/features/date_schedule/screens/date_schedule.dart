import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_dating_app_prototype/common/widgets/effects/shimmer_effect.dart';
import 'package:mini_dating_app_prototype/features/date_schedule/screens/widgets/build_date_card.dart';
import 'package:mini_dating_app_prototype/features/date_schedule/screens/widgets/date_schedule_not_found.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/authentication/user_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../matching_profile/controllers/account_mathcing_controller.dart';
import '../controllers/dating_schedule_controller.dart';
import 'package:intl/intl.dart';

class DatingScheduleScreen extends StatefulWidget {
  const DatingScheduleScreen({super.key});

  @override
  State<DatingScheduleScreen> createState() => _DatingScheduleScreenState();
}

class _DatingScheduleScreenState extends State<DatingScheduleScreen> {
  final matchingController = AccountMatchingController.instance;
  final scheduleController = Get.put(DatingScheduleController());
  final myId = AuthenticationRepository.instance.authUser!.uid;

  @override
  void initState() {
    super.initState();
    _initAsync();

    ///listen for changes (NO duplicate init thanks to controller check)
    ever(matchingController.currentUser, (user) async {
      if (user.matches.isNotEmpty) {
        final validMatch = await scheduleController.findValidMatch(
          myId,
          user.matches,
        );

        if (validMatch != null) {
          scheduleController.init(myId, validMatch);
        }
      }
    });
  }

  Future<void> _initAsync() async {
    final matches = matchingController.currentUser.value.matches;

    if (matches.isNotEmpty) {
      final validMatch = await scheduleController.findValidMatch(myId, matches);

      if (validMatch != null) {
        scheduleController.init(myId, validMatch);
      }
    }
  }

  @override
  void dispose() {
    ///prevent memory leak
    Get.delete<DatingScheduleController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn lịch hẹn của bạn"),
        actions: [
          Obx(() {
            final schedule = scheduleController.schedule.value;
            if (schedule == null) return const SizedBox();

            final userRepo = UserRepository.instance;

            return FutureBuilder(
              future: Future.wait([
                userRepo.getUserById(schedule.users[0]),
                userRepo.getUserById(schedule.users[1]),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        TShimmerEffect(width: 40, height: 40, radius: 100),
                        SizedBox(width: 10),
                        TShimmerEffect(width: 40, height: 40, radius: 100),
                      ],
                    ),
                  );
                }

                final userA = snapshot.data![0];
                final userB = snapshot.data![1];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            (userA?.profilePicture != null &&
                                userA!.profilePicture.isNotEmpty)
                            ? NetworkImage(userA.profilePicture)
                            : AssetImage(
                                    (userA?.gender.toLowerCase() == 'nữ')
                                        ? TImages.userImageWoman
                                        : TImages.userImageMale,
                                  )
                                  as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            (userB?.profilePicture != null &&
                                userB!.profilePicture.isNotEmpty)
                            ? NetworkImage(userB.profilePicture)
                            : AssetImage(
                                    (userB?.gender.toLowerCase() == 'nữ')
                                        ? TImages.userImageWoman
                                        : TImages.userImageMale,
                                  )
                                  as ImageProvider,
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        final user = matchingController.currentUser.value;

        if (user.matches.isEmpty) {
          return const EmptyDateSchedule();
        }

        final schedule = scheduleController.schedule.value;
        final state = scheduleController.state.value;

        if (state == ScheduleState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state == ScheduleState.empty) {
          return const EmptyDateSchedule();
        }

        if (schedule == null) {
          return const EmptyDateSchedule();
        }

        final isFinished = schedule.finished == true;
        if (isFinished) {
          return const EmptyDateSchedule();
        }

        final isFinalized =
            schedule.slots.isNotEmpty &&
            schedule.slots.every(
              (slot) => slot.userAStatus == "yes" && slot.userBStatus == "yes",
            );

        final isEnded =
            schedule.slots.isNotEmpty &&
            schedule.slots.every((slot) => slot.status == "ended");

        if (isFinalized) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "💖 Hai bạn có date hẹn vào",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// 📅 LIST FIRST
              Expanded(
                child: ListView.builder(
                  itemCount: schedule.slots.length,
                  itemBuilder: (_, index) {
                    final slot = schedule.slots[index];
                    return DateCardWidget(slot: slot,index: index);
                  },
                ),
              ),

              /// 🔥 BUTTON AT BOTTOM
              if (isEnded)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await scheduleController.finishAndFindNewMatch(myId);
                        },
                        child: const Text("Kết thúc lịch hẹn"),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return ListView.builder(
          itemCount: schedule.slots.length + 1,
          itemBuilder: (_, index) {
            if (index == schedule.slots.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    await scheduleController.confirmSchedule();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    side: const BorderSide(color: TColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: TSizes.lg,
                    ),
                    child: Text(
                      'Chốt lịch hẹn',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              );
            }

            final slot = schedule.slots[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Builder(
                builder: (_) {
                  final isUserA = schedule.users[0] == myId;

                  final myStatus = isUserA
                      ? slot.userAStatus
                      : slot.userBStatus;

                  final otherStatus = isUserA
                      ? slot.userBStatus
                      : slot.userAStatus;

                  Widget buildCell(String status, bool isMe) {
                    Color bg;
                    IconData icon;

                    if (status == "yes") {
                      bg = Colors.green;
                      icon = Icons.check;
                    } else if (status == "no") {
                      bg = Colors.red;
                      icon = Icons.close;
                    } else {
                      bg = Colors.grey.shade300;
                      icon = Icons.question_mark;
                    }

                    return GestureDetector(
                      onTap: isMe
                          ? () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                        title: const Text("Sẵn sàng"),
                                        onTap: () {
                                          Navigator.pop(context);
                                          scheduleController.updateSlot(
                                            index,
                                            "yes",
                                            myId,
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        title: const Text("Chưa sẵn sàng"),
                                        onTap: () {
                                          Navigator.pop(context);
                                          scheduleController.updateSlot(
                                            index,
                                            "no",
                                            myId,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white),
                      ),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// ⏰ TIME (LEFT)
                      Text(
                        DateFormat(
                          'EEEE, dd/MM - HH:mm',
                          'vi_VN',
                        ).format(slot.time),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      /// ✅ BUTTONS (RIGHT)
                      Row(
                        children: isUserA
                            ? [
                                buildCell(myStatus, true),
                                const SizedBox(width: 12),
                                buildCell(otherStatus, false),
                              ]
                            : [
                                buildCell(otherStatus, false),
                                const SizedBox(width: 12),
                                buildCell(myStatus, true),
                              ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
