import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_provider.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String? selectedState;
  String? selectedCity;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool showCities = false;

  final Map<String, List<String>> stateCities = IndianLocation.getStateCities();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<String> getFilteredStates() {
    final states = stateCities.keys.toList()..sort();
    if (searchQuery.isEmpty) {
      return states;
    }
    return states
        .where((state) => state.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<String> getFilteredCities() {
    if (selectedState == null) return [];
    final cities = stateCities[selectedState] ?? [];
    if (searchQuery.isEmpty) {
      return cities;
    }
    return cities
        .where((city) => city.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.white,
              AppColors.lightBlue.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (showCities) {
                              setState(() {
                                showCities = false;
                                selectedCity = null;
                                searchQuery = '';
                                searchController.clear();
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.greyBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              showCities ? 'Select City' : 'Select State',
                              style: AppTextStyles.header3.copyWith(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.greyBackground,
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        style: AppTextStyles.inputText,
                        decoration: InputDecoration(
                          hintText: showCities ? 'Search cities...' : 'Search states...',
                          hintStyle: AppTextStyles.inputHint,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.greyText,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.greyText,
                            ),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                searchController.clear();
                              });
                            },
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Breadcrumb
              if (selectedState != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'India',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.greyText,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.greyText,
                      ),
                      Text(
                        selectedState!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // List Content
              Expanded(
                child: showCities
                    ? _buildCityList()
                    : _buildStateList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateList() {
    final states = getFilteredStates();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: states.length,
      itemBuilder: (context, index) {
        final state = states[index];
        final isSelected = selectedState == state;
        final citiesCount = stateCities[state]?.length ?? 0;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedState = state;
              selectedCity = null;
              searchQuery = '';
              searchController.clear();
              showCities = true;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              border: Border.all(
                color: isSelected ? AppColors.primaryRed : AppColors.borderGrey,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.lightRed.withOpacity(0.2),
                        AppColors.primaryRed.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: AppColors.primaryRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$citiesCount cities available',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.greyText,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCityList() {
    final cities = getFilteredCities();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final isSelected = selectedCity == city;

        return GestureDetector(
          onTap: () {
            Navigator.pop(context, {
              'state': selectedState!,
              'city': city,
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  AppColors.lightRed.withOpacity(0.1),
                  AppColors.selectedBackground,
                ],
              )
                  : null,
              color: isSelected ? null : AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              border: Border.all(
                color: isSelected ? AppColors.primaryRed : AppColors.borderGrey,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryRed.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [AppColors.lightRed, AppColors.primaryRed],
                    )
                        : LinearGradient(
                      colors: [
                        AppColors.lightBlue,
                        AppColors.lightBlue.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: isSelected ? AppColors.white : AppColors.primaryRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    city,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primaryRed : AppColors.darkText,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.lightRed, AppColors.primaryRed],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}