class ServiceProviderType {
  final String id;
  final String title;
  final String description;
  final String icon;

  ServiceProviderType({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  static List<ServiceProviderType> getTypes() {
    return [
      ServiceProviderType(
        id: 'installer',
        title: 'Installer',
        description:
            'Provide products installation & maintenance service to end users.',
        icon: '🔧',
      ),
      ServiceProviderType(
        id: 'reseller',
        title: 'Reseller',
        description:
            'Bulk purchase products from distributors and sell to installers.',
        icon: '💼',
      ),
      ServiceProviderType(
        id: 'distributor',
        title: 'Distributor',
        description:
            'Trade and supply products to other businesses that sell to end users.',
        icon: '🏢',
      ),
    ];
  }
}

class JobTitle {
  final String title;

  JobTitle({required this.title});

  static List<JobTitle> getJobTitles() {
    return [
      JobTitle(title: 'Boss/CEO'),
      JobTitle(title: 'Manager'),
      JobTitle(title: 'Sales Executive'),
      JobTitle(title: 'Engineer'),
      JobTitle(title: 'Technical Support'),
      JobTitle(title: 'Business Development'),
      JobTitle(title: 'Operations Manager'),
      JobTitle(title: 'Project Manager'),
    ];
  }
}
