import 'package:dio/dio.dart';

/// Free medication search using multiple APIs:
/// - OpenFDA (drug labels) - https://api.fda.gov
/// - RxNorm (NIH medication names) - https://rxnav.nlm.nih.gov
/// No API keys required
class MedicationSearchService {
  static final MedicationSearchService _instance = MedicationSearchService._internal();
  factory MedicationSearchService() => _instance;
  MedicationSearchService._internal();

  late final Dio _openFdaDio;
  late final Dio _rxNormDio;
  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _openFdaDio = Dio(
      BaseOptions(
        baseUrl: 'https://api.fda.gov',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    _rxNormDio = Dio(
      BaseOptions(
        baseUrl: 'https://rxnav.nlm.nih.gov/REST',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    _initialized = true;
  }

  /// Search medications using multiple free APIs
  Future<List<Map<String, dynamic>>> searchMedications(String query) async {
    if (query.isEmpty) return [];
    if (query.length < 2) return [];
    
    // Search both APIs in parallel
    final results = await Future.wait([
      _searchOpenFDA(query).catchError((_) => <Map<String, dynamic>>[]),
      _searchRxNorm(query).catchError((_) => <Map<String, dynamic>>[]),
    ]);
    
    final openFdaResults = results[0];
    final rxNormResults = results[1];
    
    // Merge and deduplicate by name
    final allResults = <Map<String, dynamic>>[];
    final seenNames = <String>{};
    
    for (final med in [...openFdaResults, ...rxNormResults]) {
      final name = med['name']?.toString().toLowerCase().trim() ?? '';
      if (name.isNotEmpty && !seenNames.contains(name)) {
        seenNames.add(name);
        allResults.add(med);
      }
    }
    
    return allResults.take(15).toList();
  }

  /// Search OpenFDA drug label API
  Future<List<Map<String, dynamic>>> _searchOpenFDA(String query) async {
    try {
      final response = await _openFdaDio.get(
        '/drug/label.json',
        queryParameters: {
          'search': 'openfda.brand_name:"$query"+openfda.generic_name:"$query"',
          'limit': 10,
        },
      );

      final results = response.data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return [];

      return results.map((item) {
        final openFda = item['openfda'] as Map<String, dynamic>? ?? {};
        final brandNames = (openFda['brand_name'] as List<dynamic>?) ?? [];
        final genericNames = (openFda['generic_name'] as List<dynamic>?) ?? [];
        final substanceNames = (openFda['substance_name'] as List<dynamic>?) ?? [];
        
        final name = brandNames.isNotEmpty 
            ? brandNames.first.toString()
            : genericNames.isNotEmpty
                ? genericNames.first.toString()
                : substanceNames.isNotEmpty
                    ? substanceNames.first.toString()
                    : 'Unknown';

        final dosage = _extractDosageFromOpenFDA(item);
        final category = _categorizeFromOpenFDA(openFda);

        return {
          'name': name,
          'generic_name': genericNames.isNotEmpty ? genericNames.first.toString() : name,
          'brand_name': brandNames.isNotEmpty ? brandNames.first.toString() : '',
          'dosage': dosage,
          'category': category,
          'source': 'OpenFDA',
        };
      }).where((m) => m['name'] != 'Unknown').toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Search RxNorm API for medication names
  Future<List<Map<String, dynamic>>> _searchRxNorm(String query) async {
    try {
      // Step 1: Get approximate matches
      final approxResponse = await _rxNormDio.get(
        '/approximateTerm.json',
        queryParameters: {
          'term': query,
          'maxEntries': 10,
        },
      );

      final candidates = approxResponse.data['approximateGroup']?['candidate'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return [];

      // Step 2: Get details for each candidate
      final results = <Map<String, dynamic>>[];
      final seenRxcuis = <String>{};
      
      for (final candidate in candidates.take(5)) {
        final rxcui = candidate['rxcui']?.toString();
        if (rxcui == null || seenRxcuis.contains(rxcui)) continue;
        seenRxcuis.add(rxcui);

        // Get drug properties
        final propsResponse = await _rxNormDio.get(
          '/rxcui/$rxcui/properties.json',
        );
        
        final props = propsResponse.data['properties'];
        if (props == null) continue;

        final name = props['name']?.toString() ?? candidate['name']?.toString() ?? 'Unknown';
        final strength = props['strength']?.toString() ?? '';
        
        // Get RxNorm name
        final nameResponse = await _rxNormDio.get(
          '/rxcui/$rxcui.json',
        );
        final rxNormName = nameResponse.data['idGroup']?['name']?.toString();
        
        results.add({
          'name': rxNormName ?? name,
          'generic_name': name,
          'brand_name': '',
          'dosage': strength.isNotEmpty ? strength : _extractDosageFromName(name),
          'category': 'Medication',
          'source': 'RxNorm',
        });
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  String _extractDosageFromOpenFDA(Map<String, dynamic> item) {
    // Try dosage form first
    final dosageForm = item['dosage_form']?.toString() ?? '';
    if (dosageForm.isNotEmpty) return dosageForm;
    
    // Try active ingredient
    final activeIngredient = item['active_ingredient']?.toString() ?? '';
    if (activeIngredient.isNotEmpty) {
      final match = RegExp(r'(\d+\s*(?:mg|mcg|IU|g|ml|MG|MCG|IU|G|ML))').firstMatch(activeIngredient);
      if (match != null) return match.group(0) ?? '';
    }
    
    // Try dosage and administration
    final dosageAdmin = item['dosage_and_administration']?.toString() ?? '';
    if (dosageAdmin.isNotEmpty) {
      final match = RegExp(r'(\d+\s*(?:mg|mcg|IU|g|ml|MG|MCG|IU|G|ML))').firstMatch(dosageAdmin);
      if (match != null) return match.group(0) ?? '';
    }
    
    return '';
  }

  String _extractDosageFromName(String name) {
    final match = RegExp(r'(\d+\s*(?:mg|mcg|IU|g|ml|MG|MCG|IU|G|ML))').firstMatch(name);
    return match?.group(0) ?? '';
  }

  String _categorizeFromOpenFDA(Map<String, dynamic> openFda) {
    final productType = (openFda['product_type'] as List<dynamic>?)?.first?.toString() ?? '';
    if (productType.contains('OTC')) return 'OTC Medication';
    if (productType.contains('PRESCRIPTION')) return 'Prescription';
    return 'Medication';
  }

  /// Local fallback medication database - 200+ items
  static List<Map<String, dynamic>> get localMedications => [
    // Vitamins
    {'name': 'Vitamin D3', 'dosage': '2000 IU', 'category': 'Vitamin'},
    {'name': 'Vitamin B12', 'dosage': '1000 mcg', 'category': 'Vitamin'},
    {'name': 'Vitamin C', 'dosage': '1000 mg', 'category': 'Vitamin'},
    {'name': 'Vitamin K2', 'dosage': '100 mcg', 'category': 'Vitamin'},
    {'name': 'Folic Acid', 'dosage': '400 mcg', 'category': 'Vitamin'},
    {'name': 'Biotin', 'dosage': '10000 mcg', 'category': 'Vitamin'},
    {'name': 'Niacin', 'dosage': '500 mg', 'category': 'Vitamin'},
    {'name': 'Riboflavin', 'dosage': '100 mg', 'category': 'Vitamin'},
    {'name': 'Thiamine', 'dosage': '100 mg', 'category': 'Vitamin'},
    {'name': 'Pantothenic Acid', 'dosage': '500 mg', 'category': 'Vitamin'},
    {'name': 'Pyridoxine', 'dosage': '100 mg', 'category': 'Vitamin'},
    {'name': 'Vitamin A', 'dosage': '10000 IU', 'category': 'Vitamin'},
    {'name': 'Vitamin E', 'dosage': '400 IU', 'category': 'Vitamin'},
    {'name': 'Multivitamin', 'dosage': '1 tablet', 'category': 'Vitamin'},
    {'name': 'Prenatal Vitamin', 'dosage': '1 tablet', 'category': 'Vitamin'},
    // Minerals
    {'name': 'Magnesium Glycinate', 'dosage': '400 mg', 'category': 'Mineral'},
    {'name': 'Zinc Picolinate', 'dosage': '25 mg', 'category': 'Mineral'},
    {'name': 'Iron', 'dosage': '18 mg', 'category': 'Mineral'},
    {'name': 'Calcium Carbonate', 'dosage': '600 mg', 'category': 'Mineral'},
    {'name': 'Selenium', 'dosage': '200 mcg', 'category': 'Mineral'},
    {'name': 'Chromium', 'dosage': '200 mcg', 'category': 'Mineral'},
    {'name': 'Potassium', 'dosage': '99 mg', 'category': 'Mineral'},
    {'name': 'Iodine', 'dosage': '150 mcg', 'category': 'Mineral'},
    {'name': 'Manganese', 'dosage': '10 mg', 'category': 'Mineral'},
    {'name': 'Molybdenum', 'dosage': '50 mcg', 'category': 'Mineral'},
    {'name': 'Boron', 'dosage': '3 mg', 'category': 'Mineral'},
    {'name': 'Calcium Citrate', 'dosage': '500 mg', 'category': 'Mineral'},
    {'name': 'Calcium Magnesium Zinc', 'dosage': '1 tablet', 'category': 'Mineral'},
    {'name': 'Trace Minerals', 'dosage': '1 serving', 'category': 'Mineral'},
    {'name': 'Himalayan Salt', 'dosage': '1/4 tsp', 'category': 'Mineral'},
    {'name': 'Magnesium Oil', 'dosage': '10 sprays', 'category': 'Mineral'},
    // Supplements
    {'name': 'Omega-3 Fish Oil', 'dosage': '1000 mg', 'category': 'Supplement'},
    {'name': 'CoQ10', 'dosage': '100 mg', 'category': 'Supplement'},
    {'name': 'Creatine Monohydrate', 'dosage': '5 g', 'category': 'Supplement'},
    {'name': 'Glucosamine', 'dosage': '1500 mg', 'category': 'Supplement'},
    {'name': 'Chondroitin', 'dosage': '1200 mg', 'category': 'Supplement'},
    {'name': 'Lutein', 'dosage': '20 mg', 'category': 'Supplement'},
    {'name': 'Zeaxanthin', 'dosage': '5 mg', 'category': 'Supplement'},
    {'name': 'Astaxanthin', 'dosage': '12 mg', 'category': 'Supplement'},
    {'name': 'Resveratrol', 'dosage': '250 mg', 'category': 'Supplement'},
    {'name': 'Quercetin', 'dosage': '500 mg', 'category': 'Supplement'},
    {'name': 'Berberine', 'dosage': '500 mg', 'category': 'Supplement'},
    {'name': 'Alpha Lipoic Acid', 'dosage': '300 mg', 'category': 'Supplement'},
    {'name': 'NAC (N-Acetyl Cysteine)', 'dosage': '600 mg', 'category': 'Supplement'},
    {'name': 'L-Theanine', 'dosage': '200 mg', 'category': 'Supplement'},
    {'name': 'GABA', 'dosage': '750 mg', 'category': 'Supplement'},
    {'name': '5-HTP', 'dosage': '100 mg', 'category': 'Supplement'},
    {'name': 'Hyaluronic Acid', 'dosage': '100 mg', 'category': 'Supplement'},
    {'name': 'Chondroitin Sulfate', 'dosage': '1200 mg', 'category': 'Supplement'},
    {'name': 'MSM', 'dosage': '1000 mg', 'category': 'Supplement'},
    {'name': 'SAM-e', 'dosage': '400 mg', 'category': 'Supplement'},
    {'name': 'Phosphatidylserine', 'dosage': '100 mg', 'category': 'Supplement'},
    {'name': 'Inositol', 'dosage': '500 mg', 'category': 'Supplement'},
    {'name': 'Choline', 'dosage': '300 mg', 'category': 'Supplement'},
    {'name': 'Betaine HCl', 'dosage': '650 mg', 'category': 'Supplement'},
    {'name': 'Shilajit', 'dosage': '500 mg', 'category': 'Supplement'},
    {'name': 'Fulvic Acid', 'dosage': '250 mg', 'category': 'Supplement'},
    {'name': 'Colostrum', 'dosage': '500 mg', 'category': 'Supplement'},
    {'name': 'Royal Jelly', 'dosage': '1000 mg', 'category': 'Supplement'},
    {'name': 'Bee Pollen', 'dosage': '500 mg', 'category': 'Supplement'},
    {'name': 'Propolis', 'dosage': '500 mg', 'category': 'Supplement'},
    {'name': 'Manuka Honey', 'dosage': '1 tsp', 'category': 'Supplement'},
    {'name': 'Apple Cider Vinegar', 'dosage': '15 ml', 'category': 'Supplement'},
    {'name': 'Colloidal Silver', 'dosage': '1 tsp', 'category': 'Supplement'},
    {'name': 'Molecular Hydrogen', 'dosage': '1 tablet', 'category': 'Supplement'},
    // Herbs
    {'name': 'Ashwagandha', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Turmeric Curcumin', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Rhodiola Rosea', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Panax Ginseng', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Ginkgo Biloba', 'dosage': '120 mg', 'category': 'Herb'},
    {'name': 'Saw Palmetto', 'dosage': '320 mg', 'category': 'Herb'},
    {'name': 'Milk Thistle', 'dosage': '300 mg', 'category': 'Herb'},
    {'name': 'Dandelion Root', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Nettle Leaf', 'dosage': '300 mg', 'category': 'Herb'},
    {'name': 'Hawthorn Berry', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Elderberry', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Echinacea', 'dosage': '400 mg', 'category': 'Herb'},
    {'name': 'Garlic Extract', 'dosage': '1000 mg', 'category': 'Herb'},
    {'name': 'Aloe Vera', 'dosage': '100 mg', 'category': 'Herb'},
    {'name': 'Maca Root', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Tribulus Terrestris', 'dosage': '750 mg', 'category': 'Herb'},
    {'name': 'Fenugreek', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Lemon Balm', 'dosage': '300 mg', 'category': 'Herb'},
    {'name': 'Passionflower', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Valerian Root', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Chamomile', 'dosage': '400 mg', 'category': 'Herb'},
    {'name': 'Peppermint', 'dosage': '350 mg', 'category': 'Herb'},
    {'name': 'Ginger Root', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Cinnamon', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Cayenne Pepper', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Black Pepper (Piperine)', 'dosage': '10 mg', 'category': 'Herb'},
    {'name': 'Cloves', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Cumin', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Coriander', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Fennel', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Cardamom', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Holy Basil (Tulsi)', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Bacopa Monnieri', 'dosage': '300 mg', 'category': 'Herb'},
    {'name': 'Gotu Kola', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Slippery Elm', 'dosage': '400 mg', 'category': 'Herb'},
    {'name': 'Marshmallow Root', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Licorice Root', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'DGL (Deglycyrrhizinated Licorice)', 'dosage': '400 mg', 'category': 'Herb'},
    {'name': 'Astragalus', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Andrographis', 'dosage': '400 mg', 'category': 'Herb'},
    {'name': 'Olive Leaf Extract', 'dosage': '500 mg', 'category': 'Herb'},
    {'name': 'Grapefruit Seed Extract', 'dosage': '250 mg', 'category': 'Herb'},
    // Proteins
    {'name': 'Whey Protein', 'dosage': '25 g', 'category': 'Protein'},
    {'name': 'Collagen Peptides', 'dosage': '10 g', 'category': 'Protein'},
    {'name': 'Bone Broth Protein', 'dosage': '20 g', 'category': 'Protein'},
    {'name': 'Egg White Protein', 'dosage': '25 g', 'category': 'Protein'},
    {'name': 'Pea Protein', 'dosage': '25 g', 'category': 'Protein'},
    {'name': 'Rice Protein', 'dosage': '25 g', 'category': 'Protein'},
    {'name': 'Hemp Protein', 'dosage': '25 g', 'category': 'Protein'},
    {'name': 'Pumpkin Seed Protein', 'dosage': '25 g', 'category': 'Protein'},
    // Amino Acids
    {'name': 'L-Glutamine', 'dosage': '5 g', 'category': 'Amino Acid'},
    {'name': 'BCAA', 'dosage': '5 g', 'category': 'Amino Acid'},
    {'name': 'EAAs', 'dosage': '10 g', 'category': 'Amino Acid'},
    {'name': 'Beta-Alanine', 'dosage': '3 g', 'category': 'Amino Acid'},
    {'name': 'Citrulline Malate', 'dosage': '6 g', 'category': 'Amino Acid'},
    {'name': 'Arginine', 'dosage': '3 g', 'category': 'Amino Acid'},
    {'name': 'Lysine', 'dosage': '1000 mg', 'category': 'Amino Acid'},
    {'name': 'Methionine', 'dosage': '500 mg', 'category': 'Amino Acid'},
    {'name': 'Taurine', 'dosage': '1000 mg', 'category': 'Amino Acid'},
    {'name': 'Carnitine', 'dosage': '500 mg', 'category': 'Amino Acid'},
    {'name': 'Acetyl-L-Carnitine', 'dosage': '500 mg', 'category': 'Amino Acid'},
    // Oils
    {'name': 'MCT Oil', 'dosage': '15 ml', 'category': 'Oil'},
    {'name': 'Krill Oil', 'dosage': '1000 mg', 'category': 'Oil'},
    {'name': 'Cod Liver Oil', 'dosage': '1000 mg', 'category': 'Oil'},
    {'name': 'Flaxseed Oil', 'dosage': '1000 mg', 'category': 'Oil'},
    {'name': 'Evening Primrose Oil', 'dosage': '1000 mg', 'category': 'Oil'},
    {'name': 'Black Seed Oil', 'dosage': '1000 mg', 'category': 'Oil'},
    {'name': 'CBD Oil', 'dosage': '25 mg', 'category': 'Oil'},
    // Probiotics
    {'name': 'Probiotics', 'dosage': '50B CFU', 'category': 'Probiotic'},
    {'name': 'Probiotics (100B)', 'dosage': '1 capsule', 'category': 'Probiotic'},
    {'name': 'Saccharomyces Boulardii', 'dosage': '250 mg', 'category': 'Probiotic'},
    // Superfoods
    {'name': 'Spirulina', 'dosage': '3 g', 'category': 'Superfood'},
    {'name': 'Chlorella', 'dosage': '3 g', 'category': 'Superfood'},
    {'name': 'Moringa', 'dosage': '500 mg', 'category': 'Superfood'},
    {'name': 'Chia Seeds', 'dosage': '15 g', 'category': 'Superfood'},
    {'name': 'Flax Seeds', 'dosage': '15 g', 'category': 'Superfood'},
    {'name': 'Hemp Seeds', 'dosage': '15 g', 'category': 'Superfood'},
    {'name': 'Pumpkin Seeds', 'dosage': '15 g', 'category': 'Superfood'},
    {'name': 'Sunflower Seeds', 'dosage': '15 g', 'category': 'Superfood'},
    {'name': 'Sesame Seeds', 'dosage': '15 g', 'category': 'Superfood'},
    // Fiber
    {'name': 'Psyllium Husk', 'dosage': '5 g', 'category': 'Fiber'},
    {'name': 'Acacia Fiber', 'dosage': '5 g', 'category': 'Fiber'},
    {'name': 'Inulin', 'dosage': '5 g', 'category': 'Fiber'},
    {'name': 'Konjac Root (Glucomannan)', 'dosage': '1 g', 'category': 'Fiber'},
    {'name': 'Pectin', 'dosage': '5 g', 'category': 'Fiber'},
    {'name': 'Beta-Glucan', 'dosage': '3 g', 'category': 'Fiber'},
    // Hormones
    {'name': 'Melatonin', 'dosage': '3 mg', 'category': 'Hormone'},
    {'name': 'DHEA', 'dosage': '25 mg', 'category': 'Hormone'},
    {'name': 'Pregnenolone', 'dosage': '30 mg', 'category': 'Hormone'},
    {'name': '7-Keto DHEA', 'dosage': '100 mg', 'category': 'Hormone'},
    // Beverages
    {'name': 'Green Tea', 'dosage': '1 cup', 'category': 'Beverage'},
    {'name': 'Matcha', 'dosage': '2 g', 'category': 'Beverage'},
    {'name': 'Yerba Mate', 'dosage': '1 cup', 'category': 'Beverage'},
    {'name': 'Kombucha', 'dosage': '1 cup', 'category': 'Beverage'},
    {'name': 'Kefir', 'dosage': '1 cup', 'category': 'Beverage'},
    {'name': 'Coconut Water', 'dosage': '1 cup', 'category': 'Beverage'},
    {'name': 'Electrolyte Water', 'dosage': '1 bottle', 'category': 'Beverage'},
    // OTC Medications
    {'name': 'Aspirin', 'dosage': '81 mg', 'category': 'OTC Medication'},
    {'name': 'Ibuprofen', 'dosage': '200 mg', 'category': 'OTC Medication'},
    {'name': 'Acetaminophen', 'dosage': '500 mg', 'category': 'OTC Medication'},
    {'name': 'Naproxen', 'dosage': '220 mg', 'category': 'OTC Medication'},
    {'name': 'Loratadine', 'dosage': '10 mg', 'category': 'OTC Medication'},
    {'name': 'Cetirizine', 'dosage': '10 mg', 'category': 'OTC Medication'},
    {'name': 'Fexofenadine', 'dosage': '180 mg', 'category': 'OTC Medication'},
    {'name': 'Diphenhydramine', 'dosage': '25 mg', 'category': 'OTC Medication'},
    {'name': 'Omeprazole', 'dosage': '20 mg', 'category': 'OTC Medication'},
    {'name': 'Famotidine', 'dosage': '20 mg', 'category': 'OTC Medication'},
    {'name': 'Simethicone', 'dosage': '80 mg', 'category': 'OTC Medication'},
    {'name': 'Lactase', 'dosage': '9000 FCC', 'category': 'OTC Medication'},
    {'name': 'Pepto-Bismol', 'dosage': '30 ml', 'category': 'OTC Medication'},
    {'name': 'Imodium', 'dosage': '2 mg', 'category': 'OTC Medication'},
    {'name': 'Dramamine', 'dosage': '50 mg', 'category': 'OTC Medication'},
    {'name': 'Pseudoephedrine', 'dosage': '60 mg', 'category': 'OTC Medication'},
    {'name': 'Guaifenesin', 'dosage': '400 mg', 'category': 'OTC Medication'},
    {'name': 'Dextromethorphan', 'dosage': '15 mg', 'category': 'OTC Medication'},
    {'name': 'Mucinex', 'dosage': '600 mg', 'category': 'OTC Medication'},
    {'name': 'Claritin', 'dosage': '10 mg', 'category': 'OTC Medication'},
    {'name': 'Zyrtec', 'dosage': '10 mg', 'category': 'OTC Medication'},
    {'name': 'Allegra', 'dosage': '180 mg', 'category': 'OTC Medication'},
    {'name': 'Flonase', 'dosage': '1 spray', 'category': 'OTC Medication'},
    {'name': 'Nasacort', 'dosage': '1 spray', 'category': 'OTC Medication'},
    {'name': 'Visine', 'dosage': '1-2 drops', 'category': 'OTC Medication'},
    {'name': 'Refresh Tears', 'dosage': '1-2 drops', 'category': 'OTC Medication'},
    {'name': 'Neosporin', 'dosage': 'Apply thin layer', 'category': 'OTC Medication'},
    {'name': 'Hydrocortisone Cream', 'dosage': 'Apply thin layer', 'category': 'OTC Medication'},
    {'name': 'Calamine Lotion', 'dosage': 'Apply as needed', 'category': 'OTC Medication'},
    {'name': 'Tylenol', 'dosage': '500 mg', 'category': 'OTC Medication'},
    {'name': 'Advil', 'dosage': '200 mg', 'category': 'OTC Medication'},
    {'name': 'Aleve', 'dosage': '220 mg', 'category': 'OTC Medication'},
    {'name': 'Excedrin', 'dosage': '2 tablets', 'category': 'OTC Medication'},
    {'name': 'Midol', 'dosage': '2 tablets', 'category': 'OTC Medication'},
    {'name': 'Theraflu', 'dosage': '1 packet', 'category': 'OTC Medication'},
    {'name': 'NyQuil', 'dosage': '30 ml', 'category': 'OTC Medication'},
    {'name': 'DayQuil', 'dosage': '30 ml', 'category': 'OTC Medication'},
    {'name': 'Robitussin', 'dosage': '20 ml', 'category': 'OTC Medication'},
    {'name': 'Delsym', 'dosage': '10 ml', 'category': 'OTC Medication'},
    {'name': 'Sudafed', 'dosage': '60 mg', 'category': 'OTC Medication'},
    {'name': 'Miralax', 'dosage': '17 g', 'category': 'OTC Medication'},
    {'name': 'Dulcolax', 'dosage': '5 mg', 'category': 'OTC Medication'},
    {'name': 'Senokot', 'dosage': '8.6 mg', 'category': 'OTC Medication'},
    {'name': 'Colace', 'dosage': '100 mg', 'category': 'OTC Medication'},
    {'name': 'Gas-X', 'dosage': '80 mg', 'category': 'OTC Medication'},
    {'name': 'Tums', 'dosage': '2 tablets', 'category': 'OTC Medication'},
    {'name': 'Rolaids', 'dosage': '2 tablets', 'category': 'OTC Medication'},
    {'name': 'Pepcid', 'dosage': '20 mg', 'category': 'OTC Medication'},
    {'name': 'Prilosec OTC', 'dosage': '20 mg', 'category': 'OTC Medication'},
    {'name': 'Nexium', 'dosage': '20 mg', 'category': 'OTC Medication'},
    {'name': 'Prevacid', 'dosage': '15 mg', 'category': 'OTC Medication'},
    {'name': 'Zofran', 'dosage': '4 mg', 'category': 'OTC Medication'},
    {'name': 'Bonine', 'dosage': '25 mg', 'category': 'OTC Medication'},
    {'name': 'Preparation H', 'dosage': 'Apply as needed', 'category': 'OTC Medication'},
    // Prescription Medications
    {'name': 'Metformin', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Atorvastatin', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Simvastatin', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Rosuvastatin', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Lisinopril', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Amlodipine', 'dosage': '5 mg', 'category': 'Prescription'},
    {'name': 'Losartan', 'dosage': '50 mg', 'category': 'Prescription'},
    {'name': 'Valsartan', 'dosage': '80 mg', 'category': 'Prescription'},
    {'name': 'Metoprolol', 'dosage': '50 mg', 'category': 'Prescription'},
    {'name': 'Atenolol', 'dosage': '50 mg', 'category': 'Prescription'},
    {'name': 'Carvedilol', 'dosage': '12.5 mg', 'category': 'Prescription'},
    {'name': 'Hydrochlorothiazide', 'dosage': '25 mg', 'category': 'Prescription'},
    {'name': 'Furosemide', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Spironolactone', 'dosage': '25 mg', 'category': 'Prescription'},
    {'name': 'Levothyroxine', 'dosage': '50 mcg', 'category': 'Prescription'},
    {'name': 'Warfarin', 'dosage': '5 mg', 'category': 'Prescription'},
    {'name': 'Rivaroxaban', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Apixaban', 'dosage': '5 mg', 'category': 'Prescription'},
    {'name': 'Clopidogrel', 'dosage': '75 mg', 'category': 'Prescription'},
    {'name': 'Prednisone', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Methylprednisolone', 'dosage': '4 mg', 'category': 'Prescription'},
    {'name': 'Hydrocortisone', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Methotrexate', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Hydroxychloroquine', 'dosage': '200 mg', 'category': 'Prescription'},
    {'name': 'Sulfasalazine', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Azathioprine', 'dosage': '50 mg', 'category': 'Prescription'},
    {'name': 'Cyclosporine', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Tacrolimus', 'dosage': '1 mg', 'category': 'Prescription'},
    {'name': 'Mycophenolate', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Leflunomide', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Gabapentin', 'dosage': '300 mg', 'category': 'Prescription'},
    {'name': 'Pregabalin', 'dosage': '75 mg', 'category': 'Prescription'},
    {'name': 'Duloxetine', 'dosage': '60 mg', 'category': 'Prescription'},
    {'name': 'Venlafaxine', 'dosage': '75 mg', 'category': 'Prescription'},
    {'name': 'Amitriptyline', 'dosage': '25 mg', 'category': 'Prescription'},
    {'name': 'Nortriptyline', 'dosage': '25 mg', 'category': 'Prescription'},
    {'name': 'Mirtazapine', 'dosage': '15 mg', 'category': 'Prescription'},
    {'name': 'Trazodone', 'dosage': '50 mg', 'category': 'Prescription'},
    {'name': 'Bupropion', 'dosage': '150 mg', 'category': 'Prescription'},
    {'name': 'Sertraline', 'dosage': '50 mg', 'category': 'Prescription'},
    {'name': 'Fluoxetine', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Paroxetine', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Citalopram', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Escitalopram', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Lithium', 'dosage': '300 mg', 'category': 'Prescription'},
    {'name': 'Valproic Acid', 'dosage': '250 mg', 'category': 'Prescription'},
    {'name': 'Carbamazepine', 'dosage': '200 mg', 'category': 'Prescription'},
    {'name': 'Oxcarbazepine', 'dosage': '300 mg', 'category': 'Prescription'},
    {'name': 'Lamotrigine', 'dosage': '25 mg', 'category': 'Prescription'},
    {'name': 'Topiramate', 'dosage': '25 mg', 'category': 'Prescription'},
    {'name': 'Levetiracetam', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Phenytoin', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Phenobarbital', 'dosage': '30 mg', 'category': 'Prescription'},
    {'name': 'Clonazepam', 'dosage': '0.5 mg', 'category': 'Prescription'},
    {'name': 'Lorazepam', 'dosage': '1 mg', 'category': 'Prescription'},
    {'name': 'Alprazolam', 'dosage': '0.5 mg', 'category': 'Prescription'},
    {'name': 'Diazepam', 'dosage': '5 mg', 'category': 'Prescription'},
    {'name': 'Temazepam', 'dosage': '15 mg', 'category': 'Prescription'},
    {'name': 'Zolpidem', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Eszopiclone', 'dosage': '2 mg', 'category': 'Prescription'},
    {'name': 'Ramelteon', 'dosage': '8 mg', 'category': 'Prescription'},
    {'name': 'Armodafinil', 'dosage': '150 mg', 'category': 'Prescription'},
    {'name': 'Modafinil', 'dosage': '200 mg', 'category': 'Prescription'},
    {'name': 'Methylphenidate', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Amphetamine', 'dosage': '20 mg', 'category': 'Prescription'},
    {'name': 'Lisdexamfetamine', 'dosage': '30 mg', 'category': 'Prescription'},
    {'name': 'Atomoxetine', 'dosage': '40 mg', 'category': 'Prescription'},
    {'name': 'Guanfacine', 'dosage': '1 mg', 'category': 'Prescription'},
    {'name': 'Clonidine', 'dosage': '0.1 mg', 'category': 'Prescription'},
    {'name': 'Allopurinol', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Colchicine', 'dosage': '0.6 mg', 'category': 'Prescription'},
    {'name': 'Phenergan', 'dosage': '25 mg', 'category': 'Prescription'},
    {'name': 'Insulin', 'dosage': 'As prescribed', 'category': 'Prescription'},
    {'name': 'Ozempic', 'dosage': '0.25 mg', 'category': 'Prescription'},
    {'name': 'Wegovy', 'dosage': '0.25 mg', 'category': 'Prescription'},
    {'name': 'Mounjaro', 'dosage': '2.5 mg', 'category': 'Prescription'},
    {'name': 'Trulicity', 'dosage': '0.75 mg', 'category': 'Prescription'},
    {'name': 'Victoza', 'dosage': '0.6 mg', 'category': 'Prescription'},
    {'name': 'Januvia', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Farxiga', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Jardiance', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Glipizide', 'dosage': '5 mg', 'category': 'Prescription'},
    {'name': 'Pioglitazone', 'dosage': '15 mg', 'category': 'Prescription'},
    {'name': 'Albuterol', 'dosage': '90 mcg', 'category': 'Prescription'},
    {'name': 'Flovent', 'dosage': '110 mcg', 'category': 'Prescription'},
    {'name': 'Advair', 'dosage': '100/50 mcg', 'category': 'Prescription'},
    {'name': 'Symbicort', 'dosage': '160/4.5 mcg', 'category': 'Prescription'},
    {'name': 'Spiriva', 'dosage': '18 mcg', 'category': 'Prescription'},
    {'name': 'Singulair', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Xolair', 'dosage': '150 mg', 'category': 'Prescription'},
    {'name': 'Dupixent', 'dosage': '300 mg', 'category': 'Prescription'},
    {'name': 'Nucala', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Prednisolone', 'dosage': '5 mg', 'category': 'Prescription'},
    {'name': 'Budesonide', 'dosage': '0.5 mg', 'category': 'Prescription'},
    {'name': 'Fluticasone', 'dosage': '50 mcg', 'category': 'Prescription'},
    {'name': 'Ipratropium', 'dosage': '17 mcg', 'category': 'Prescription'},
    {'name': 'Tiotropium', 'dosage': '18 mcg', 'category': 'Prescription'},
    {'name': 'Theophylline', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Azithromycin', 'dosage': '250 mg', 'category': 'Prescription'},
    {'name': 'Amoxicillin', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Cephalexin', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Ciprofloxacin', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Levofloxacin', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Doxycycline', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Clindamycin', 'dosage': '300 mg', 'category': 'Prescription'},
    {'name': 'Metronidazole', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Fluconazole', 'dosage': '150 mg', 'category': 'Prescription'},
    {'name': 'Terbinafine', 'dosage': '250 mg', 'category': 'Prescription'},
    {'name': 'Acyclovir', 'dosage': '400 mg', 'category': 'Prescription'},
    {'name': 'Valacyclovir', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Oseltamivir', 'dosage': '75 mg', 'category': 'Prescription'},
    {'name': 'Amoxicillin-Clavulanate', 'dosage': '875/125 mg', 'category': 'Prescription'},
    {'name': 'Trimethoprim-Sulfamethoxazole', 'dosage': '800/160 mg', 'category': 'Prescription'},
    {'name': 'Nitrofurantoin', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Cefuroxime', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Cefdinir', 'dosage': '300 mg', 'category': 'Prescription'},
    {'name': 'Moxifloxacin', 'dosage': '400 mg', 'category': 'Prescription'},
    {'name': 'Tetracycline', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Minocycline', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Erythromycin', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Clarithromycin', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Linezolid', 'dosage': '600 mg', 'category': 'Prescription'},
    {'name': 'Vancomycin', 'dosage': '125 mg', 'category': 'Prescription'},
    {'name': 'Ivermectin', 'dosage': '3 mg', 'category': 'Prescription'},
    {'name': 'Albendazole', 'dosage': '400 mg', 'category': 'Prescription'},
    {'name': 'Mebendazole', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Praziquantel', 'dosage': '600 mg', 'category': 'Prescription'},
    {'name': 'Nystatin', 'dosage': '500000 units', 'category': 'Prescription'},
    {'name': 'Griseofulvin', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Itraconazole', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Ketoconazole', 'dosage': '200 mg', 'category': 'Prescription'},
    {'name': 'Voriconazole', 'dosage': '200 mg', 'category': 'Prescription'},
    {'name': 'Anidulafungin', 'dosage': '100 mg', 'category': 'Prescription'},
    {'name': 'Caspofungin', 'dosage': '50 mg', 'category': 'Prescription'},
    {'name': 'Micafungin', 'dosage': '50 mg', 'category': 'Prescription'},
    {'name': 'Flucytosine', 'dosage': '2500 mg', 'category': 'Prescription'},
    {'name': 'Zanamivir', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Peramivir', 'dosage': '600 mg', 'category': 'Prescription'},
    {'name': 'Baloxavir', 'dosage': '40 mg', 'category': 'Prescription'},
    {'name': 'Remdesivir', 'dosage': '200 mg', 'category': 'Prescription'},
    {'name': 'Molnupiravir', 'dosage': '200 mg', 'category': 'Prescription'},
    {'name': 'Paxlovid', 'dosage': '300 mg', 'category': 'Prescription'},
    {'name': 'Tamiflu', 'dosage': '75 mg', 'category': 'Prescription'},
    {'name': 'Relenza', 'dosage': '10 mg', 'category': 'Prescription'},
    {'name': 'Xofluza', 'dosage': '40 mg', 'category': 'Prescription'},
    {'name': 'Evusheld', 'dosage': '150 mg', 'category': 'Prescription'},
    {'name': 'Bebtelovimab', 'dosage': '175 mg', 'category': 'Prescription'},
    {'name': 'Sotrovimab', 'dosage': '500 mg', 'category': 'Prescription'},
    {'name': 'Regeneron', 'dosage': '1200 mg', 'category': 'Prescription'},
  ];

  /// Search local medication database
  static List<Map<String, dynamic>> searchLocal(String query) {
    if (query.isEmpty) return localMedications;
    final lowerQuery = query.toLowerCase();
    return localMedications
        .where((m) => m['name'].toString().toLowerCase().contains(lowerQuery))
        .toList();
  }
}
