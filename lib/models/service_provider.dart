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
        description: 'Provide products installation & maintenance service to end users.',
        icon: '🔧',
      ),
      ServiceProviderType(
        id: 'reseller',
        title: 'Reseller',
        description: 'Bulk purchase products from distributors and sell to installers.',
        icon: '💼',
      ),
      ServiceProviderType(
        id: 'distributor',
        title: 'Distributor',
        description: 'Trade and supply products to other businesses that sell to end users.',
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

class IndianLocation {
  static Map<String, List<String>> getStateCities() {
    return {
      'Punjab': [
        'Ludhiana',
        'Amritsar',
        'Jalandhar',
        'Patiala',
        'Bathinda',
        'Mohali',
        'Pathankot',
        'Hoshiarpur',
        'Batala',
        'Moga',
        'Malerkotla',
        'Khanna',
        'Phagwara',
        'Muktsar',
        'Barnala',
        'Rajpura',
        'Firozpur',
        'Kapurthala',
        'Faridkot',
        'Sunam',
      ],
      'Delhi': [
        'Central Delhi',
        'East Delhi',
        'New Delhi',
        'North Delhi',
        'North East Delhi',
        'North West Delhi',
        'Shahdara',
        'South Delhi',
        'South East Delhi',
        'South West Delhi',
        'West Delhi',
      ],
      'Maharashtra': [
        'Mumbai',
        'Pune',
        'Nagpur',
        'Thane',
        'Nashik',
        'Aurangabad',
        'Solapur',
        'Kolhapur',
        'Amravati',
        'Navi Mumbai',
        'Sangli',
        'Malegaon',
        'Jalgaon',
        'Akola',
        'Latur',
      ],
      'Karnataka': [
        'Bangalore',
        'Mysore',
        'Hubli',
        'Mangalore',
        'Belgaum',
        'Davangere',
        'Bellary',
        'Bijapur',
        'Shimoga',
        'Tumkur',
        'Gulbarga',
      ],
      'Tamil Nadu': [
        'Chennai',
        'Coimbatore',
        'Madurai',
        'Tiruchirappalli',
        'Salem',
        'Tirunelveli',
        'Tiruppur',
        'Erode',
        'Vellore',
        'Thoothukudi',
      ],
      'Gujarat': [
        'Ahmedabad',
        'Surat',
        'Vadodara',
        'Rajkot',
        'Bhavnagar',
        'Jamnagar',
        'Junagadh',
        'Gandhinagar',
        'Anand',
        'Nadiad',
      ],
      'Uttar Pradesh': [
        'Lucknow',
        'Kanpur',
        'Ghaziabad',
        'Agra',
        'Varanasi',
        'Meerut',
        'Prayagraj',
        'Bareilly',
        'Aligarh',
        'Moradabad',
        'Noida',
        'Greater Noida',
      ],
      'West Bengal': [
        'Kolkata',
        'Howrah',
        'Durgapur',
        'Asansol',
        'Siliguri',
        'Bardhaman',
        'Malda',
        'Baharampur',
        'Kharagpur',
      ],
      'Haryana': [
        'Faridabad',
        'Gurgaon',
        'Rohtak',
        'Panipat',
        'Karnal',
        'Sonipat',
        'Yamunanagar',
        'Panchkula',
        'Bhiwani',
        'Ambala',
      ],
      'Rajasthan': [
        'Jaipur',
        'Jodhpur',
        'Kota',
        'Bikaner',
        'Ajmer',
        'Udaipur',
        'Bhilwara',
        'Alwar',
        'Bharatpur',
        'Sikar',
      ],
      'Telangana': [
        'Hyderabad',
        'Warangal',
        'Nizamabad',
        'Karimnagar',
        'Ramagundam',
        'Khammam',
        'Mahbubnagar',
        'Nalgonda',
      ],
    };
  }
}