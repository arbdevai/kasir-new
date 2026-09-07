import 'package:flutter/material.dart';

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
                                  Text(profile.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(profile.tagline, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                  const SizedBox(height: 16),
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
                          title: Text(widget.state.selectedPrinterName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: Text('Ukuran kertas: ${widget.state.selectedPaperSize}'),
                          value: widget.state.isPrinterConnected,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            widget.state.updatePrinterSettings(isConnected: val);
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
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
                            const SizedBox(width: 8),
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Backup terenkripsi berhasil dibuat di penyimpanan lokal')),
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.restart_alt_rounded, color: AppColors.warning),
                          title: const Text('Reset Data Dummy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          subtitle: const Text('Bersihkan data transaksi sample untuk mulai baru'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data transaksi disiapkan untuk produksi')),
                            );
                          },
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
