import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../src/backup.dart';
import '../state/pos_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final PosState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final profile = widget.state.storeProfile;

        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              floating: true,
              pinned: true,
              toolbarHeight: 64,
              titleSpacing: 20,
              title: Text('Pengaturan & Profil', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile.tagline,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                              onPressed: () => _editStoreProfile(context),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _infoTile(Icons.location_on_outlined, 'Alamat', profile.address),
                        _infoTile(Icons.phone_outlined, 'Kontak', profile.phone),
                      ],
                    ),
                  ),
                  if (widget.state.currentUser.role == UserRole.owner ||
                      widget.state.currentUser.role == UserRole.manager) ...[
                    GlassPanel(child: _buildUserManagement(context)),
                    const SizedBox(height: 16),
                  ],
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Periferal & Printer Struk',
                          subtitle: 'Konfigurasi printer thermal ESC/POS 58mm/80mm',
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(widget.state.selectedPrinterName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: Text('Ukuran kertas: ${widget.state.selectedPaperSize}', maxLines: 1, overflow: TextOverflow.ellipsis),
                          value: widget.state.isPrinterConnected,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            widget.state.updatePrinterSettings(isConnected: val);
                          },
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Test print 58mm ESC/POS dikirim ke printer')),
                                );
                              },
                              icon: const Icon(Icons.print_rounded, size: 16),
                              label: const Text('Test Print'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sinyal buka laci kasir (Cash Drawer) terkirim')),
                                );
                              },
                              icon: const Icon(Icons.archive_outlined, size: 16),
                              label: const Text('Buka Cash Drawer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Pajak & Biaya Layanan',
                          subtitle: 'Pengaturan otomatis pada kalkulasi checkout',
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Aktifkan PPN / Pajak Resto (10%)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          value: profile.isTaxEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            widget.state.updateStoreProfile(profile.copyWith(isTaxEnabled: val));
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Aktifkan Biaya Layanan / Service (5%)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          value: profile.isServiceEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            widget.state.updateStoreProfile(profile.copyWith(isServiceEnabled: val));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Backup & Pemulihan Data',
                          subtitle: 'Database offline lokal aman di perangkat',
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.backup_rounded, color: AppColors.primary),
                          title: const Text('Backup Database (.kasir)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: const Text('Cadangkan data penjualan, katalog & stok'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () async {
                            final artifact = await VersionedJsonBackupService(widget.state).createBackup();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Backup ${artifact.fileName} berhasil dibuat (${artifact.bytes.length} byte)')),
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.upload_file_rounded, color: AppColors.primary),
                          title: const Text('Import / Pulihkan Data (.kasir)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: const Text('Tempel atau muat JSON backup lalu pulihkan'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showImportDialog(context),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.delete_forever_rounded, color: AppColors.danger),
                          title: const Text('Reset Data', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: const Text('Hapus seluruh transaksi, stok, shift; butuh PIN Owner'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showResetTotalDataDialog(context),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoTile(IconData icon, String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $val',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement(BuildContext context) {
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: SectionHeader(
                title: 'Manajemen Akun & Pengguna',
                subtitle: 'Kelola akun Owner, Manager, dan Kasir',
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Tambah pengguna',
              icon: const Icon(Icons.person_add_alt_rounded),
              onPressed: () => _showUserForm(context),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...state.users.map((user) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: user.isActive ? AppColors.primary : AppColors.textSecondary,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            subtitle: Text(
              '${user.roleTitle} • ${user.isActive ? 'Aktif' : 'Nonaktif'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: user.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (_) => state.toggleUserStatus(user.id),
                ),
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showUserForm(context, existing: user),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showUserForm(BuildContext context, {UserAccount? existing}) {
    final nameC = TextEditingController(text: existing?.name ?? '');
    final pinC = TextEditingController();
    UserRole role = existing?.role ?? UserRole.cashier;
    bool isActive = existing?.isActive ?? true;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Tambah Pengguna' : 'Edit Pengguna',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama')),
                const SizedBox(height: 10),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: UserRole.owner, child: Text('Owner')),
                    DropdownMenuItem(value: UserRole.manager, child: Text('Manager')),
                    DropdownMenuItem(value: UserRole.cashier, child: Text('Cashier')),
                  ],
                  onChanged: (value) {
                    if (value != null) setSheetState(() => role = value);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pinC,
                  decoration: InputDecoration(
                    labelText: existing == null ? 'PIN (4-6 digit angka)' : 'PIN baru (opsional, 4-6 digit angka)',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Akun aktif', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setSheetState(() => isActive = val),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final ok = _validateAndSaveUser(
                        existing: existing,
                        name: nameC.text,
                        role: role,
                        pinText: pinC.text,
                        isActive: isActive,
                      );
                      if (ok == null) {
                        Navigator.pop(ctx);
                      } else {
                        setSheetState(() => error = ok);
                      }
                    },
                    child: Text(existing == null ? 'Tambah Pengguna' : 'Simpan Perubahan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Validates user form input and persists. Returns an error message or null.
  String? _validateAndSaveUser({
    required UserAccount? existing,
    required String name,
    required UserRole role,
    required String pinText,
    required bool isActive,
  }) {
    if (name.trim().isEmpty) return 'Nama tidak boleh kosong';
    final pinPattern = RegExp(r'^\d{4,6}$');
    if (existing == null) {
      if (!pinPattern.hasMatch(pinText)) return 'PIN harus 4-6 digit angka';
      final ok = widget.state.addUserAccount(
        name: name,
        role: role,
        pin: pinText,
        isActive: isActive,
      );
      return ok ? null : 'Gagal menambah pengguna, periksa input';
    }
    if (pinText.isNotEmpty && !pinPattern.hasMatch(pinText)) {
      return 'PIN harus 4-6 digit angka';
    }
    final ok = widget.state.updateUserAccount(
      existing.id,
      name: name,
      role: role,
      pin: pinText.isEmpty ? null : pinText,
      isActive: isActive,
    );
    return ok ? null : 'Gagal menyimpan pengguna, periksa input';
  }

  void _showResetTotalDataDialog(BuildContext context) {
    final pinC = TextEditingController();
    String? error;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Reset Total Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PERINGATAN: seluruh transaksi, keranjang, mutasi stok, shift aktif & riwayat, katalog, dan pengaturan akan dihapus dan dikembalikan ke awal. Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinC,
                decoration: const InputDecoration(labelText: 'PIN Owner'),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final ok = widget.state.resetTotalData(ownerPin: pinC.text);
                if (ok) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seluruh data berhasil direset')),
                  );
                } else {
                  setDialogState(() => error = 'PIN Owner tidak valid');
                }
              },
              child: const Text('Reset Semua'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final inputC = TextEditingController();
    String? message;
    bool isError = false;
    bool working = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Import / Pulihkan Data (.kasir)'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tempel isi JSON backup (.kasir) di bawah. Backup diverifikasi magic/version/checksum sebelum dipulihkan.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: inputC,
                    decoration: const InputDecoration(
                      labelText: 'Isi backup JSON',
                      hintText: '{"magic": "KASIR_BACKUP", ...}',
                    ),
                    maxLines: 8,
                    minLines: 4,
                  ),
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        message!,
                        style: TextStyle(
                          color: isError ? AppColors.danger : AppColors.success,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: working
                  ? null
                  : () async {
                      setDialogState(() {
                        working = true;
                        message = null;
                      });
                      final raw = inputC.text.trim();
                      if (raw.isEmpty) {
                        setDialogState(() {
                          working = false;
                          message = 'Isi backup tidak boleh kosong';
                          isError = true;
                        });
                        return;
                      }
                      Uint8List bytes;
                      try {
                        bytes = Uint8List.fromList(utf8.encode(raw));
                      } catch (_) {
                        setDialogState(() {
                          working = false;
                          message = 'Isi backup tidak dapat dibaca';
                          isError = true;
                        });
                        return;
                      }
                      final service = VersionedJsonBackupService(widget.state);
                      final validation = await service.validateBackup(bytes);
                      if (!validation.isValid) {
                        setDialogState(() {
                          working = false;
                          message = 'Backup tidak valid: ${validation.message}';
                          isError = true;
                        });
                        return;
                      }
                      try {
                        await service.restoreBackup(bytes);
                      } catch (e) {
                        setDialogState(() {
                          working = false;
                          message = 'Gagal memulihkan backup: $e';
                          isError = true;
                        });
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup berhasil dipulihkan')),
                      );
                    },
              child: const Text('Validasi & Pulihkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _editStoreProfile(BuildContext context) {
    final nameC = TextEditingController(text: widget.state.storeProfile.name);
    final tagC = TextEditingController(text: widget.state.storeProfile.tagline);
    final addrC = TextEditingController(text: widget.state.storeProfile.address);
    final phoneC = TextEditingController(text: widget.state.storeProfile.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Informasi Toko', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama Toko')),
              const SizedBox(height: 10),
              TextField(controller: tagC, decoration: const InputDecoration(labelText: 'Tagline / Deskripsi')),
              const SizedBox(height: 10),
              TextField(controller: addrC, decoration: const InputDecoration(labelText: 'Alamat Toko')),
              const SizedBox(height: 10),
              TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'Nomor WhatsApp / Telp')),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.state.updateStoreProfile(widget.state.storeProfile.copyWith(
                      name: nameC.text,
                      tagline: tagC.text,
                      address: addrC.text,
                      phone: phoneC.text,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan Profil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
