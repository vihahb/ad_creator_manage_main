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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Campaign' : 'Create Campaign'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCampaign,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildGeographicTargetingSection(),
              const SizedBox(height: 24),
              _buildDemographicTargetingSection(),
              if (isEditing) ...[
                const SizedBox(height: 24),
                _buildMetricsSection(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saveCampaign,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
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
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Campaign Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a campaign name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedChannel,
          decoration: const InputDecoration(
            labelText: 'Channel',
            border: OutlineInputBorder(),
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
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _budgetController,
          decoration: const InputDecoration(
            labelText: 'Budget (\$)',
            border: OutlineInputBorder(),
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Select Date',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Select Date',
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
        const Text(
          'Geographic Targeting',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Add Location',
                  border: OutlineInputBorder(),
                  hintText: 'Enter city, state, or region',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addLocation,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_locations.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _locations.map((location) {
              return Chip(
                label: Text(location),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _locations.remove(location);
                  });
                },
              );
            }).toList(),
          ),
        if (_locations.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No locations added. Add at least one location for targeting.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildDemographicTargetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Demographic Targeting',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minAgeController,
                decoration: const InputDecoration(
                  labelText: 'Min Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxAgeController,
                decoration: const InputDecoration(
                  labelText: 'Max Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Target Gender',
            border: OutlineInputBorder(),
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
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _occupationController,
          decoration: const InputDecoration(
            labelText: 'Target Occupation',
            border: OutlineInputBorder(),
            hintText: 'e.g., Students, Professionals, Retirees',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _interestController,
                decoration: const InputDecoration(
                  labelText: 'Add Interest',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Sports, Technology, Fashion',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addInterest,
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_interests.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests.map((interest) {
              return Chip(
                label: Text(interest),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _interests.remove(interest);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campaign Metrics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _impressionsController,
                decoration: const InputDecoration(
                  labelText: 'Impressions',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _clicksController,
                decoration: const InputDecoration(
                  labelText: 'Clicks',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Conversions',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Actual Cost (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
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
        title: const Text('Delete Campaign'),
        content: const Text('Are you sure you want to delete this campaign? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
            const SnackBar(
              content: Text('Campaign deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting campaign: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}