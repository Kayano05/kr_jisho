import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/dictionary_entry.dart';
import '../widgets/wave_clipper.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DictionaryEntry> _allEntries = [];
  List<DictionaryEntry> _exactMatches = [];
  List<DictionaryEntry> _partialMatches = [];
  List<DictionaryEntry> _filteredEntries = [];
  List<String> _searchHistory = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _showingNoResults = false;
  String _currentTip = '';
  bool _showTip = false;

  final List<String> _tips = [
    "Learn a new word every day to boost your vocabulary!",
    "Make sentences with new words for better memory!",
    "Listen to Japanese songs and watch dramas to improve listening!",
    "Regular review makes vocabulary easier to remember!",
    "Practice pronunciation to improve your speaking skills!"
  ];

  @override
  void initState() {
    super.initState();
    _loadDictionary();
    _loadSearchHistory();
    _setRandomTip();
  }

  void _setRandomTip() {
    _currentTip = (_tips..shuffle()).first;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showTip = true;
        });
      }
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _loadDictionary() async {
    try {
      final List<String> dictionaryFiles = [
        'assets/data/dictionary.json',
        'assets/data/n1.json',
        'assets/data/n1_2.json',
        'assets/data/n2.json',
        'assets/data/n3.json',
        'assets/data/n4.json',
        'assets/data/neo_add.json'
      ];

      List<DictionaryEntry> allEntries = [];

      for (String file in dictionaryFiles) {
        try {
          final String jsonString = await rootBundle.loadString(file);
          final List<dynamic> jsonList = json.decode(jsonString);
          allEntries.addAll(
            jsonList.map((json) => DictionaryEntry.fromJson(json)).toList()
          );
        } catch (e) {
          debugPrint('Error loading dictionary file $file: $e');
        }
      }

      setState(() {
        _allEntries = allEntries;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in _loadDictionary: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
      _showingNoResults = false;
    });

    if (query.isEmpty) {
      setState(() {
        _exactMatches = [];
        _partialMatches = [];
        _filteredEntries = [];
        _isSearching = false;
      });
      return;
    }

    final lowercasedQuery = query.toLowerCase();
    
    final exactMatches = _allEntries.where((entry) {
      return entry.word.toLowerCase() == lowercasedQuery ||
             entry.kana.toLowerCase() == lowercasedQuery;
    }).toList();

    final partialMatches = _allEntries.where((entry) {
      if (exactMatches.contains(entry)) return false;
      return entry.word.toLowerCase().contains(lowercasedQuery) ||
             entry.kana.toLowerCase().contains(lowercasedQuery) ||
             entry.examples.any((example) => example.toLowerCase().contains(lowercasedQuery));
    }).toList();

    setState(() {
      _exactMatches = exactMatches;
      _partialMatches = partialMatches;
      _filteredEntries = [...exactMatches, ...partialMatches];
      _isSearching = false;
      _showingNoResults = _filteredEntries.isEmpty;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _exactMatches = [];
      _partialMatches = [];
      _filteredEntries = [];
      _isSearching = false;
      _showingNoResults = false;
    });
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory = [];
    });
  }

  Future<void> _addToSearchHistory(String query) async {
    if (query.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          Container(color: themeProvider.backgroundColor),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: themeProvider.accentColor,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: themeProvider.textColor),
                    decoration: InputDecoration(
                      hintText: 'Enter word to search...',
                      hintStyle: TextStyle(color: themeProvider.textColor.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search, color: themeProvider.textColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: themeProvider.textColor),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: themeProvider.backgroundColor.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: themeProvider.accentColor, width: 2),
                      ),
                    ),
                    onChanged: _performSearch,
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.accentColor),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: themeProvider.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _searchController.text.isEmpty
                              ? _buildSearchHistory(themeProvider)
                              : _buildSearchResults(themeProvider),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(ThemeProvider themeProvider) {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Text(
          'No Search History',
          style: TextStyle(
            color: themeProvider.textColor.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              TextButton(
                onPressed: _clearSearchHistory,
                child: Text(
                  'Clear',
                  style: TextStyle(color: themeProvider.accentColor),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final query = _searchHistory[index];
              return ListTile(
                leading: Icon(
                  Icons.history,
                  color: themeProvider.accentColor,
                ),
                title: Text(
                  query,
                  style: TextStyle(
                    color: themeProvider.textColor,
                  ),
                ),
                onTap: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(ThemeProvider themeProvider) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(themeProvider.accentColor),
        ),
      );
    }

    if (_showingNoResults) {
      return Center(
        child: Text(
          'No Results Found',
          style: TextStyle(
            color: themeProvider.textColor.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_exactMatches.isNotEmpty) ...[
          Text(
            'Exact Matches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          ..._exactMatches.asMap().entries.map((entry) {
            return TweenAnimationBuilder(
              key: ValueKey(entry.value.word),
              duration: Duration(milliseconds: 400 + (entry.key * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WordCard(entry: entry.value),
              ),
            );
          }),
        ],
        if (_partialMatches.isNotEmpty) ...[
          if (_exactMatches.isNotEmpty) const SizedBox(height: 16),
          Text(
            'Partial Matches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          ..._partialMatches.asMap().entries.map((entry) {
            final delay = _exactMatches.length + entry.key;
            return TweenAnimationBuilder(
              key: ValueKey(entry.value.word),
              duration: Duration(milliseconds: 400 + (delay * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WordCard(entry: entry.value),
              ),
            );
          }),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  void _onSearchSubmitted(String query) {
    _addToSearchHistory(query);
    _performSearch(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class WordCard extends StatefulWidget {
  final DictionaryEntry entry;

  const WordCard({
    super.key,
    required this.entry,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Card(
          elevation: 5,
          shadowColor: themeProvider.textColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: themeProvider.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.entry.word,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.entry.partOfSpeech,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.entry.kana,
                  style: TextStyle(
                    fontSize: 18,
                    color: themeProvider.textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.entry.examples.first,
                  style: TextStyle(
                    fontSize: 18,
                    color: themeProvider.textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.entry.examples.skip(1).map((example) {
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            example,
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.textColor.withOpacity(0.7),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  crossFadeState: _showDetails 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                  sizeCurve: Curves.easeOutCubic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 