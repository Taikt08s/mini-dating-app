import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_dating_app_prototype/utils/constants/image_strings.dart';

import '../../../../../common/widgets/effects/shimmer_effect.dart';
import '../../../../authentication/models/user_models.dart';
import '../../../controllers/account_mathcing_controller.dart';

class AccountMatchingCard extends StatelessWidget {
  final UserModel user;

  const AccountMatchingCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final controller = AccountMatchingController.instance;

    return Stack(
      children: [
        /// 🔥 BACKGROUND IMAGE (WITH SHIMMER)
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.75,
            child: user.profilePicture.isNotEmpty
                ? Image.network(
              user.profilePicture,
              fit: BoxFit.cover,

              /// 🔥 SHIMMER WHILE LOADING
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return TShimmerEffect(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.75,
                  radius: 24,
                );
              },

              /// 🔥 ERROR FALLBACK (ALSO SHIMMER -> IMAGE)
              errorBuilder: (_, _, _) {
                return Image.asset(
                  user.gender.toLowerCase() == 'nữ'
                      ? TImages.userImageWoman
                      : TImages.userImageMale,
                  fit: BoxFit.cover,
                );
              },
            )
                : Image.asset(
              user.gender.toLowerCase() == 'nữ'
                  ? TImages.userImageWoman
                  : TImages.userImageMale,
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// 🔥 DARK GRADIENT OVERLAY
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        /// 🔥 USER INFO
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${user.name}, ${user.age}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                user.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: (user.hobbies ?? [])
                    .map(
                      (hobby) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hobby,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),

              const SizedBox(height: 16),

              Obx(() {
                final isLiked = controller.isLiked(user.id);

                return Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.likeUser(user),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLiked
                              ? Colors.pink
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}