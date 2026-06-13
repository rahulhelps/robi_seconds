/// Domain placeholder — replace when user data is loaded from a repository.
class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.jobTitle,
    required this.avatarUrl,
  });

  final String displayName;
  final String jobTitle;
  final String avatarUrl;

  static const sample = UserProfile(
    displayName: 'John Doe',
    jobTitle: 'Marketing Manager',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBzx3LUcnL18XGU0-Le4puL67abog8VOBqg2cYelgLBXmR3k7D5RSlvaGXbrIG36kCCfT7ZHSu-0sLakiRz5uTW-Phv_XmECh7BjdMskIogE-ElbiNx0NZxSf_J6Sjs5pDVSHtuW-1YtN67-mDPxHLqXtHtii6DyZuC5c09cDGKBLjYcRfXVW2ZLJNprqQPDroYd51bTwsNK9VcIt7a9A9vI-wHSZeEYim46GbcUQ-vRLFgdsCn8y-DVmP78GyNeXOVz05Nc28xU2c',
  );
}
