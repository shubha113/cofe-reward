import 'package:flutter/material.dart';
import 'package:csc_picker/model/select_status_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../constants/app_constants.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  // Data Storage
  List<dynamic> allData = [];
  List<String> countries = [];
  List<String> states = [];
  List<String> cities = [];

  // Selections
  String? selectedCountry;
  String? selectedState;

  // UI Control
  String selectionMode = 'country'; // 'country', 'state', 'city'
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from the package assets
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      // Fetching the raw data from csc_picker's bundled asset
      String jsonString = await rootBundle.loadString(
        'packages/csc_picker/lib/assets/country.json',
      );
      List<dynamic> res = json.decode(jsonString);

      setState(() {
        allData = res;
        countries = res.map((item) => item['name'].toString()).toList();
        countries.sort();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<String> getFilteredList() {
    String query = searchQuery.toLowerCase();
    List<String> currentList = [];
    if (selectionMode == 'country')
      currentList = countries;
    else if (selectionMode == 'state')
      currentList = states;
    else
      currentList = cities;

    if (query.isEmpty) return currentList;
    return currentList
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  void _handleBack() {
    if (selectionMode == 'city') {
      setState(() {
        selectionMode = 'state';
        searchQuery = '';
        searchController.clear();
      });
    } else if (selectionMode == 'state') {
      setState(() {
        selectionMode = 'country';
        selectedCountry = null;
        searchQuery = '';
        searchController.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = selectionMode == 'country'
        ? 'Select Country'
        : selectionMode == 'state'
        ? 'Select State'
        : 'Select City';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.white,
              AppColors.lightBlue.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(title),
              _buildBreadcrumb(),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryRed,
                        ),
                      )
                    : _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                onPressed: _handleBack,
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
                    title,
                    style: AppTextStyles.header3.copyWith(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (val) => setState(() => searchQuery = val),
        style: AppTextStyles.inputText,
        decoration: InputDecoration(
          hintText: 'Search $selectionMode...',
          hintStyle: AppTextStyles.inputHint,
          prefixIcon: const Icon(Icons.search, color: AppColors.greyText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    if (selectionMode == 'country') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 16, color: AppColors.primaryRed),
          const SizedBox(width: 4),
          if (selectedCountry != null) ...[
            Text(selectedCountry!, style: AppTextStyles.bodySmall),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.greyText,
            ),
          ],
          if (selectedState != null)
            Text(
              selectedState!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final list = getFilteredList();
    if (list.isEmpty) return const Center(child: Text("No results found"));

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final String name = list[index];
        return GestureDetector(
          onTap: () => _handleItemTap(name),
          child: _buildListItem(name),
        );
      },
    );
  }

  void _handleItemTap(String name) {
    if (selectionMode == 'country') {
      selectedCountry = name;
      var countryData = allData.firstWhere((c) => c['name'] == name);
      states = (countryData['state'] as List)
          .map((s) => s['name'].toString())
          .toList();
      states.sort();
      setState(() {
        selectionMode = 'state';
        searchQuery = '';
        searchController.clear();
      });
    } else if (selectionMode == 'state') {
      selectedState = name;
      var countryData = allData.firstWhere((c) => c['name'] == selectedCountry);
      var stateData = (countryData['state'] as List).firstWhere(
        (s) => s['name'] == name,
      );
      cities = (stateData['city'] as List)
          .map((c) => c['name'].toString())
          .toList();
      cities.sort();
      setState(() {
        selectionMode = 'city';
        searchQuery = '';
        searchController.clear();
      });
    } else {
      Navigator.pop(context, {
        'country': selectedCountry,
        'state': selectedState,
        'city': name,
      });
    }
  }

  Widget _buildListItem(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
            child: Icon(
              selectionMode == 'country' ? Icons.public : Icons.location_city,
              color: AppColors.primaryRed,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(name, style: AppTextStyles.bodyLarge)),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.greyText,
          ),
        ],
      ),
    );
  }
}
