import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawvera/controllers/service_provider_controller.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  static const Color primaryTeal = Color(0xFF2D6A64);

  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _customPetTypeController = TextEditingController();
  bool _activateImmediately = true;
  Set<String> _formPetTypes = {}; // pet types for the current form

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _customPetTypeController.dispose();
    super.dispose();
  }

  void _openServiceForm({
    String? serviceId,
    String? name,
    String? description,
    double? price,
    String? duration,
    bool? isActive,
    List<String>? petTypes,
  }) {
    if (serviceId != null) {
      _nameController.text = name ?? '';
      _descController.text = description ?? '';
      _priceController.text = price?.toStringAsFixed(2) ?? '';
      _durationController.text = duration ?? '';
      _activateImmediately = isActive ?? true;
      _formPetTypes = Set.from(petTypes ?? []);
    } else {
      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _durationController.clear();
      _activateImmediately = true;
      _formPetTypes = {};
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => _buildServiceFormUI(
          setModalState,
          isEdit: serviceId != null,
          editServiceId: serviceId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProviderController>(
      builder: (context, ctrl, _) {
        final services = ctrl.services;
        final displayList = _searchQuery.isEmpty
            ? services
            : services
                  .where(
                    (s) => s.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Manage Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openServiceForm(),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    "Add Service",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (ctrl.loading)
              const Center(child: CircularProgressIndicator())
            else if (displayList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No services found."),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final service = displayList[index];
                  return _buildServiceCard(service, ctrl);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(dynamic service, ServiceProviderController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildActiveBadge(service.isActive),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            service.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "${service.price.toStringAsFixed(2)} JOD",
                style: const TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 15),
              Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                service.duration,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openServiceForm(
                    serviceId: service.id,
                    name: service.name,
                    description: service.description,
                    price: service.price,
                    duration: service.duration,
                    isActive: service.isActive,
                    petTypes: service.petTypes,
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ctrl.updateService(
                      serviceId: service.id,
                      isActive: !service.isActive,
                    );
                  },
                  icon: Icon(
                    service.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 16,
                  ),
                  label: Text(service.isActive ? "Deactivate" : "Activate"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFormUI(
    StateSetter setModalState, {
    required bool isEdit,
    String? editServiceId,
  }) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Edit Service" : "Add New Service",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildLabel("Service Name *"),
            _buildTextField(_nameController, "e.g., Full Grooming Package"),
            const SizedBox(height: 15),
            _buildLabel("Description *"),
            _buildTextField(
              _descController,
              "Describe the service...",
              maxLines: 3,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Price (JOD) *"),
                      _buildTextField(_priceController, "0.00"),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Duration *"),
                      _buildTextField(_durationController, "e.g., 2 hours"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Pet type selector
            _buildLabel("Available For"),
            Consumer<ServiceProviderController>(
              builder: (context, ctrl, _) {
                final shopPetTypes = ctrl.shop?.petTypes ?? [];
                // Merge shop types with any already selected (custom ones)
                final allOptions = {
                  ...shopPetTypes,
                  ..._formPetTypes,
                }.toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (allOptions.isEmpty)
                      Text(
                        "Set pet types in Shop Info first",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else ...[
                      // "All Pets" chip
                      Row(
                        children: [
                          FilterChip(
                            label: const Text("All Pets"),
                            selected: _formPetTypes.isEmpty,
                            onSelected: (_) =>
                                setModalState(() => _formPetTypes.clear()),
                            selectedColor:
                                primaryTeal.withValues(alpha: 0.15),
                            checkmarkColor: primaryTeal,
                            labelStyle: TextStyle(
                              color: _formPetTypes.isEmpty
                                  ? primaryTeal
                                  : Colors.black87,
                              fontWeight: _formPetTypes.isEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: _formPetTypes.isEmpty
                                  ? primaryTeal
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: allOptions.map((type) {
                          final selected = _formPetTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: selected,
                            onSelected: (_) => setModalState(() {
                              if (selected) {
                                _formPetTypes.remove(type);
                              } else {
                                _formPetTypes.add(type);
                              }
                            }),
                            selectedColor:
                                primaryTeal.withValues(alpha: 0.15),
                            checkmarkColor: primaryTeal,
                            labelStyle: TextStyle(
                              color:
                                  selected ? primaryTeal : Colors.black87,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? primaryTeal
                                  : Colors.grey[300]!,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    // Custom pet type input
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customPetTypeController,
                            decoration: InputDecoration(
                              hintText: "Add custom type (e.g., Rabbit)",
                              hintStyle: const TextStyle(fontSize: 12),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final val =
                                _customPetTypeController.text.trim();
                            if (val.isNotEmpty) {
                              setModalState(() {
                                _formPetTypes.add(val);
                                _customPetTypeController.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Add",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            // Activation toggle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _activateImmediately
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: _activateImmediately
                        ? primaryTeal
                        : Colors.grey[400],
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Activate service immediately",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Switch(
                    value: _activateImmediately,
                    onChanged: (value) =>
                        setModalState(() => _activateImmediately = value),
                    activeColor: primaryTeal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isNotEmpty) {
                          final ctrl = context
                              .read<ServiceProviderController>();
                          if (isEdit && editServiceId != null) {
                            ctrl.updateService(
                              serviceId: editServiceId,
                              name: _nameController.text,
                              description: _descController.text,
                              price:
                                  double.tryParse(_priceController.text) ?? 0,
                              duration: _durationController.text,
                              isActive: null,
                              petTypes: _formPetTypes.toList(),
                            );
                          } else {
                            ctrl.addService(
                              name: _nameController.text,
                              description: _descController.text,
                              price:
                                  double.tryParse(_priceController.text) ?? 0,
                              duration: _durationController.text,
                              isActive: _activateImmediately,
                              petTypes: _formPetTypes.toList(),
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isEdit ? "Update Service" : "Add Service",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
    ),
  );

  Widget _buildActiveBadge(bool isActive) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isActive
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      isActive ? "Active" : "Inactive",
      style: TextStyle(
        color: isActive ? Colors.green : Colors.grey,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
