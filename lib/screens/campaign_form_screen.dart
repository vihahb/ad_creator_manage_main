import 'package:flutter/material.dart';
import '../models/offline_campaign.dart';
import '../services/campaign_repository.dart';

class CampaignFormScreen extends StatefulWidget {
  final CampaignRepository repository;
  final OfflineCampaign? campaign;

  const CampaignFormScreen({
    Key? key,
    required this.repository,
    this.campaign,
  }) : super(key: key);

  @override
  State<CampaignFormScreen> createState() => _CampaignFormScreenState();
}

class _CampaignFormScreenState extends State<CampaignFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic campaign info
  late TextEditingController _nameController;
  String _selectedChannel = 'Business Card';
  late TextEditingController _budgetController;
  DateTime? _startDate;
  DateTime? _endDate;

  // Geographic targeting
  final List<String> _locations = [];
  final TextEditingController _locationController = TextEditingController();

  // Demographic targeting
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _occupationController = TextEditingController();
  final List<String> _interests = [];
  final TextEditingController _interestController = TextEditingController();

  // Metrics (for editing existing campaigns)
  final TextEditingController _impressionsController = TextEditingController();
  final TextEditingController _clicksController = TextEditingController();
  final TextEditingController _conversionsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  final List<String> _channels = [
    'Business Card',
    'Direct Mail',
    'Flyer',
    'TV/Radio',
    'Billboard',
    'Event',
    'Other'
  ];

  final List<String> _genderOptions = ['Male', 'Female', 'All'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final campaign = widget.campaign;
    
    _nameController = TextEditingController(text: campaign?.name ?? '');
    _selectedChannel = campaign?.channel ?? 'Business Card';
    _budgetController = TextEditingController(
      text: campaign?.budget.toString() ?? '',
    );
    _startDate = campaign?.startDate;
    _endDate = campaign?.endDate;

    // Geographic targeting
    if (campaign != null) {
      _locations.addAll(campaign.locations);
    }

    // Demographic targeting
    _minAgeController.text = campaign?.minAge?.toString() ?? '';
    _maxAgeController.text = campaign?.maxAge?.toString() ?? '';
    _selectedGender = campaign?.gender;
    _occupationController.text = campaign?.occupation ?? '';
    if (campaign != null) {
      _interests.addAll(campaign.interests);
    }

    // Metrics
    _impressionsController.text = campaign?.impressions.toString() ?? '0';
    _clicksController.text = campaign?.clicks.toString() ?? '0';
    _conversionsController.text = campaign?.conversions.toString() ?? '0';
    _costController.text = campaign?.cost.toString() ?? '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _occupationController.dispose();
    _interestController.dispose();
    _impressionsController.dispose();
    _clicksController.dispose();
    _conversionsController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.campaign != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Campaign' : 'Create Campaign'),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _deleteCampaign,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[700]!, Colors.indigo[50]!],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBasicInfoSection(),
                          const SizedBox(height: 32),
                          _buildGeographicTargetingSection(),
                          const SizedBox(height: 32),
                          _buildDemographicTargetingSection(),
                          if (isEditing) ...[
                            const SizedBox(height: 32),
                            _buildMetricsSection(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saveCampaign,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Text(
            isEditing ? 'Update Campaign' : 'Create Campaign',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.campaign_rounded, color: Colors.indigo[700], size: 24),
            const SizedBox(width: 10),
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Campaign Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
            ),
            prefixIcon: const Icon(Icons.edit_rounded),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a campaign name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _selectedChannel,
          decoration: InputDecoration(
            labelText: 'Channel',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
            ),
            prefixIcon: const Icon(Icons.category_rounded),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: _channels.map((channel) {
            return DropdownMenuItem(
              value: channel,
              child: Text(channel),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedChannel = value!;
            });
          },
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.arrow_drop_down_circle_outlined),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _budgetController,
          decoration: InputDecoration(
            labelText: 'Budget (\$)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
            ),
            prefixIcon: const Icon(Icons.attach_money_rounded),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a budget';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Select Date',
                            style: TextStyle(
                              fontWeight: _startDate != null ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 20),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Date',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Select Date',
                            style: TextStyle(
                              fontWeight: _endDate != null ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeographicTargetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: Colors.indigo[700], size: 24),
            const SizedBox(width: 10),
            const Text(
              'Geographic Targeting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Add Location',
                  hintText: 'Enter city, state, or region',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                elevation: 2,
              ),
              child: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_locations.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo[100]!),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _locations.map((location) {
                return Chip(
                  label: Text(location),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.indigo[700]),
                  deleteIcon: Icon(Icons.close_rounded, size: 18, color: Colors.indigo[700]),
                  onDeleted: () {
                    setState(() {
                      _locations.remove(location);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.indigo[200]!),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                );
              }).toList(),
            ),
          ),
        if (_locations.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.grey[500], size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No locations added. Add at least one location for targeting.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDemographicTargetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people_alt_rounded, color: Colors.indigo[700], size: 24),
            const SizedBox(width: 10),
            const Text(
              'Demographic Targeting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minAgeController,
                decoration: InputDecoration(
                  labelText: 'Min Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.child_care_rounded),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxAgeController,
                decoration: InputDecoration(
                  labelText: 'Max Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.elderly_rounded),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            labelText: 'Target Gender',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
            ),
            prefixIcon: const Icon(Icons.wc_rounded),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          hint: const Text('Select Gender'),
          items: _genderOptions.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.arrow_drop_down_circle_outlined),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _occupationController,
          decoration: InputDecoration(
            labelText: 'Target Occupation',
            hintText: 'e.g., Students, Professionals, Retirees',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
            ),
            prefixIcon: const Icon(Icons.work_rounded),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _interestController,
                decoration: InputDecoration(
                  labelText: 'Add Interest',
                  hintText: 'e.g., Sports, Technology, Fashion',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.interests_rounded),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addInterest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                elevation: 2,
              ),
              child: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_interests.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo[100]!),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interests.map((interest) {
                return Chip(
                  label: Text(interest),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.indigo[700]),
                  deleteIcon: Icon(Icons.close_rounded, size: 18, color: Colors.indigo[700]),
                  onDeleted: () {
                    setState(() {
                      _interests.remove(interest);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.indigo[200]!),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_rounded, color: Colors.indigo[700], size: 24),
            const SizedBox(width: 10),
            const Text(
              'Campaign Metrics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo[100]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _impressionsController,
                      decoration: InputDecoration(
                        labelText: 'Impressions',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        prefixIcon: const Icon(Icons.visibility_rounded),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _clicksController,
                      decoration: InputDecoration(
                        labelText: 'Clicks',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        prefixIcon: const Icon(Icons.touch_app_rounded),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _conversionsController,
                      decoration: InputDecoration(
                        labelText: 'Conversions',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(
                        labelText: 'Actual Cost (\$)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addLocation() {
    final location = _locationController.text.trim();
    if (location.isNotEmpty && !_locations.contains(location)) {
      setState(() {
        _locations.add(location);
        _locationController.clear();
      });
    }
  }

  void _addInterest() {
    final interest = _interestController.text.trim();
    if (interest.isNotEmpty && !_interests.contains(interest)) {
      setState(() {
        _interests.add(interest);
        _interestController.clear();
      });
    }
  }

  void _saveCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one location for targeting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final campaign = OfflineCampaign(
        id: widget.campaign?.id ?? widget.repository.getNextId(),
        name: _nameController.text.trim(),
        channel: _selectedChannel,
        locations: List.from(_locations),
        minAge: _minAgeController.text.isNotEmpty 
            ? int.tryParse(_minAgeController.text) 
            : null,
        maxAge: _maxAgeController.text.isNotEmpty 
            ? int.tryParse(_maxAgeController.text) 
            : null,
        gender: _selectedGender,
        occupation: _occupationController.text.isNotEmpty 
            ? _occupationController.text.trim() 
            : null,
        interests: List.from(_interests),
        startDate: _startDate!,
        endDate: _endDate!,
        budget: double.parse(_budgetController.text),
        lastUpdate: DateTime.now(),
        impressions: int.tryParse(_impressionsController.text) ?? 0,
        clicks: int.tryParse(_clicksController.text) ?? 0,
        conversions: int.tryParse(_conversionsController.text) ?? 0,
        cost: double.tryParse(_costController.text) ?? 0.0,
      );

      await widget.repository.saveCampaign(campaign);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.campaign != null 
                  ? 'Campaign updated successfully' 
                  : 'Campaign created successfully'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving campaign: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteCampaign() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
            const SizedBox(width: 10),
            const Text('Delete Campaign'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this campaign? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.campaign != null) {
      try {
        await widget.repository.deleteCampaign(widget.campaign!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 16),
                  const Text('Campaign deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(child: Text('Error deleting campaign: $e')),
                ],
              ),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }
}
