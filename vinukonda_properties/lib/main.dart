import 'dart:typed_data';
import 'dart:io' show File; // Only used on mobile/desktop. Guard with kIsWeb when needed.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VinukondaRealEstateApp());
}

class VinukondaRealEstateApp extends StatelessWidget {
  const VinukondaRealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinukonda Real Estate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2563EB),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w800),
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(height: 1.4),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    final sections = _SectionsController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderNav(onNav: (t) => sections.scrollTo(t, controller)),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionAnchor(
                      anchorKey: sections.heroKey,
                      child: const HeroSection(),
                    ),
                    SectionAnchor(
                      anchorKey: sections.featuredKey,
                      child: const FeaturedPropertiesSection(),
                    ),
                    SectionAnchor(
                      anchorKey: sections.aboutKey,
                      child: const AboutSection(),
                    ),
                    SectionAnchor(
                      anchorKey: sections.categoriesKey,
                      child: const CategoriesSection(),
                    ),
                    SectionAnchor(
                      anchorKey: sections.galleryKey,
                      child: const GallerySection(),
                    ),
                    SectionAnchor(
                      anchorKey: sections.contactKey,
                      child: const ContactSection(),
                    ),
                    const FooterSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   Navigation / Header
   ========================= */

class HeaderNav extends StatelessWidget {
  const HeaderNav({super.key, required this.onNav});
  final void Function(_SectionTarget) onNav;

  static final Uri _youtubeUri = Uri.parse(
    'https://youtube.com/@bejjamsadvinreddy?si=0NrPx5jHptGK0nTK',
  );

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '9849496057');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('Could not launch phone dialer');
    }
  }

  Future<void> _openYouTube() async {
    // Try to open the channel in YouTube app when possible; fall back to browser.
    if (!await launchUrl(_youtubeUri, mode: LaunchMode.externalApplication)) {
      await launchUrl(_youtubeUri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const _Logo(),
          const Spacer(),
          if (!isMobile)
            Row(
              children: [
                _NavBtn('Home', () => onNav(_SectionTarget.hero)),
                _NavBtn('Properties', () => onNav(_SectionTarget.featured)),
                _NavBtn('About', () => onNav(_SectionTarget.about)),
                _NavBtn('Categories', () => onNav(_SectionTarget.categories)),
                _NavBtn('Gallery', () => onNav(_SectionTarget.gallery)),
                _NavBtn('Contact', () => onNav(_SectionTarget.contact)),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _makePhoneCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A), // Green color
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Call Now'),
                ),
              ],
            )
          else
            PopupMenuButton<String>(
              tooltip: 'Menu',
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Home', child: Text('Home')),
                PopupMenuItem(value: 'Properties', child: Text('Properties')),
                PopupMenuItem(value: 'About', child: Text('About')),
                PopupMenuItem(value: 'Categories', child: Text('Categories')),
                PopupMenuItem(value: 'Gallery', child: Text('Gallery')),
                PopupMenuItem(value: 'Contact', child: Text('Contact')),
                PopupMenuItem(value: 'Call', child: Text('Call Now')), 
              ],
              onSelected: (value) {
                if (value == 'Call') {
                  _makePhoneCall();
                  return;
                }
                final map = {
                  'Home': _SectionTarget.hero,
                  'Properties': _SectionTarget.featured,
                  'About': _SectionTarget.about,
                  'Categories': _SectionTarget.categories,
                  'Gallery': _SectionTarget.gallery,
                  'Contact': _SectionTarget.contact,
                };
                onNav(map[value]!);
              },
              child: const Icon(Icons.menu, size: 28),
            ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.maps_home_work, size: 28, color: Color.fromARGB(255, 20, 151, 98)),
        const SizedBox(width: 8),
        Text('Vinukonda Properties', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(label),
      ),
    );
  }
}

/* =========================
   Hero
   ========================= */

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pad = w < 800 ? 20.0 : 40.0;

    return Container(
      padding: EdgeInsets.fromLTRB(pad, 48, pad, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Find Your Plot or Home in Vinukonda',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Verified sites, houses, and commercial plots with clear titles and local guidance.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _ChipBox(icon: Icons.location_on, label: 'Vinukonda'),
                  _ChipBox(icon: Icons.home_work, label: 'Houses & Sites'),
                  _ChipBox(icon: Icons.verified, label: 'Clear Titles'),
                  _ChipBox(icon: Icons.support_agent, label: 'Loan Assistance'),
                ],
              ),
              const SizedBox(height: 28),
              const _SearchRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipBox extends StatelessWidget {
  const _ChipBox({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      side: const BorderSide(color: Color(0xFFDBEAFE)),
      backgroundColor: const Color(0xFFF1F5FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 700;

    const boxes = [
      _DropdownBox(hint: 'Property Type', items: ['Site', 'House', 'Commercial']),
      _DropdownBox(hint: 'Budget', items: ['< ₹10L', '₹10L–₹30L', '₹30L–₹60L', '> ₹60L']),
      _DropdownBox(hint: 'Area / Locality', items: ['Town', 'Bypass', 'Near Bus Stand']),
    ];

    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: isNarrow
          ? Column(
              children: [
                ...boxes,
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ),
              ],
            )
          : const Row(
              children: [
                Expanded(child: _DropdownBox(hint: 'Property Type', items: ['Site', 'House', 'Commercial'])),
                SizedBox(width: 12),
                Expanded(child: _DropdownBox(hint: 'Budget', items: ['< ₹10L', '₹10L–₹30L', '₹30L–₹60L', '> ₹60L'])),
                SizedBox(width: 12),
                Expanded(child: _DropdownBox(hint: 'Area / Locality', items: ['Town', 'Bypass', 'Near Bus Stand'])),
                SizedBox(width: 12),
                _SearchButton(),
              ],
            ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.search),
      label: const Text('Search'),
    );
  }
}

class _DropdownBox extends StatefulWidget {
  const _DropdownBox({required this.hint, required this.items});
  final String hint;
  final List<String> items;

  @override
  State<_DropdownBox> createState() => _DropdownBoxState();
}

class _DropdownBoxState extends State<_DropdownBox> {
  String? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: widget.items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
      onChanged: (v) => setState(() => value = v),
    );
  }
}

/* =========================
   Featured Properties
   ========================= */

class FeaturedPropertiesSection extends StatelessWidget {
  const FeaturedPropertiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final props = _sampleProperties;
    final w = MediaQuery.of(context).size.width;
    final columns = w >= 1100 ? 3 : w >= 750 ? 2 : 1;

    return _SectionShell(
      title: 'Featured Properties in Vinukonda',
      subtitle: 'Fresh listings with photos and key details.',
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: props.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: 330,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (_, i) => PropertyCard(data: props[i]),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, required this.data});
  final Property data;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              image: data.imageUrl == null
                  ? null
                  : DecorationImage(image: NetworkImage(data.imageUrl!), fit: BoxFit.cover),
            ),
            child: data.imageUrl == null
                ? const Center(child: Icon(Icons.image, size: 36, color: Colors.white70))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Expanded(child: Text(data.location, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(data.price, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  _Tag(text: data.type),
                  _Tag(text: data.area),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

/* =========================
   About
   ========================= */

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isNarrow = w < 900;

    final image = Container(
      height: 220,
      margin: EdgeInsets.only(right: isNarrow ? 0 : 20, bottom: isNarrow ? 16 : 0),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1502005229762-cf1b2da7c52f?w=1200'),
          fit: BoxFit.cover,
        ),
      ),
    );

    const bullets = Column(
      children: [
        _Bullet(text: '10+ years of experience in plots & houses'),
        _Bullet(text: 'Clear titles and transparent process'),
        _Bullet(text: 'Bank loan assistance & site visits'),
        _Bullet(text: 'Local expertise in all Vinukonda areas'),
      ],
    );

    return _SectionShell(
      title: 'About Our Business',
      subtitle: 'Trusted local real estate agency in Vinukonda.',
      child: isNarrow
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [image, bullets])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: image),
              const Expanded(child: bullets),
            ]),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
      title: Text(text),
    );
  }
}

/* =========================
   Categories
   ========================= */

class CategoryItem {
  final String title;
  final IconData icon;
  const CategoryItem(this.title, this.icon);
}

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final columns = w >= 1100 ? 4 : w >= 800 ? 3 : w >= 600 ? 2 : 1;
    const cats = [
      CategoryItem('Houses', Icons.house_rounded),
      CategoryItem('Sites', Icons.terrain_rounded),
      CategoryItem('Commercial', Icons.apartment_rounded),
      CategoryItem('Agricultural', Icons.agriculture_rounded),
    ];

    return _SectionShell(
      title: 'Property Categories',
      subtitle: 'Explore by type.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cats.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: 120,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (_, i) => Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: ListTile(
              leading: Icon(cats[i].icon, size: 32, color: const Color(0xFF2563EB)),
              title: Text(cats[i].title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Vinukonda & surroundings'),
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   Gallery (Photos + Videos)
   ========================= */

class MediaItem {
  final Uint8List? bytes; // For quick thumbnails of images
  final String sourcePath; // XFile.path (file path on mobile/desktop or blob URL on web)
  final bool isVideo;
  final DateTime addedAt;
  const MediaItem({this.bytes, required this.sourcePath, required this.isVideo, required this.addedAt});
}

class GallerySection extends StatefulWidget {
  const GallerySection({super.key});

  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  final ImagePicker _picker = ImagePicker();
  final List<MediaItem> _items = [];
  bool _busy = false;

  int get _count => _items.length;

  Future<void> _pickPhotos() async {
    try {
      setState(() => _busy = true);
      final files = await _picker.pickMultiImage(imageQuality: 90);
      if (files.isEmpty) return;
      final toAdd = <MediaItem>[];
      for (final x in files) {
        final bytes = await x.readAsBytes();
        if (bytes.isNotEmpty) {
          toAdd.add(MediaItem(bytes: bytes, sourcePath: x.path, isVideo: false, addedAt: DateTime.now()));
        }
      }
      if (toAdd.isNotEmpty) setState(() => _items.addAll(toAdd));
    } catch (e) {
      _showSnack('Failed to pick photos: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickVideos() async {
    try {
      setState(() => _busy = true);
      // image_picker does not have pickMultiVideo yet on all platforms; use pickMultipleMedia.
      final files = await _picker.pickMultipleMedia();
      if (files.isEmpty) return;
      final toAdd = <MediaItem>[];
      for (final x in files) {
        final mime = x.mimeType?.toLowerCase() ?? '';
        final isVideo = mime.startsWith('video/');
        if (!isVideo) continue; // only add videos here
        toAdd.add(MediaItem(bytes: null, sourcePath: x.path, isVideo: true, addedAt: DateTime.now()));
      }
      if (toAdd.isEmpty) {
        _showSnack('No videos selected.');
      } else {
        setState(() => _items.addAll(toAdd));
      }
    } catch (e) {
      _showSnack('Failed to pick videos: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recordVideo() async {
    try {
      setState(() => _busy = true);
      final x = await _picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 5));
      if (x == null) return;
      setState(() => _items.add(MediaItem(bytes: null, sourcePath: x.path, isVideo: true, addedAt: DateTime.now())));
    } catch (e) {
      _showSnack('Failed to record video: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this item?'),
        content: const Text('This will delete the media from the gallery in this app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _items.removeAt(index));
      _showSnack('Deleted.');
    }
  }

  void _openViewer(MediaItem item) {
    if (item.isVideo) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoPlayerPage(sourcePath: item.sourcePath),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImageViewerPage(bytes: item.bytes!),
        ),
      );
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final columns = w >= 1100 ? 4 : w >= 900 ? 3 : w >= 600 ? 2 : 1;

    return _SectionShell(
      title: 'Gallery',
      subtitle: 'Upload your own Vinukonda site & home photos or videos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _pickPhotos,
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload Photos'),
              ),
              FilledButton.icon(
                onPressed: _busy ? null : _pickVideos,
                icon: const Icon(Icons.video_library),
                label: const Text('Upload Videos'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _recordVideo,
                icon: const Icon(Icons.videocam),
                label: const Text('Record Video'),
              ),
              if (_count > 0)
                TextButton.icon(
                  onPressed: _busy
                      ? null
                      : () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Remove all items?'),
                              content: const Text('This will clear all uploaded media in this session.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear All')),
                              ],
                            ),
                          );
                          if (ok == true) setState(_items.clear);
                        },
                  icon: const Icon(Icons.delete_sweep_rounded),
                  label: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Uploaded: $_count',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (_items.isEmpty)
            _EmptyGalleryHint(busy: _busy)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 200,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final item = _items[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _openViewer(item),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (!item.isVideo && item.bytes != null)
                          Image.memory(
                            item.bytes!,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            filterQuality: FilterQuality.medium,
                          )
                        else
                          Container(
                            color: const Color(0xFF0F172A),
                            child: const Center(
                              child: Icon(Icons.play_circle_fill, size: 56, color: Colors.white70),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xAA000000), Color(0x00000000)],
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(item.isVideo ? Icons.videocam : Icons.photo, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _friendlyTime(item.addedAt),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => _confirmDelete(i),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(Icons.delete, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _friendlyTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${t.year}/${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyGalleryHint extends StatelessWidget {
  const _EmptyGalleryHint({required this.busy});
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library_outlined, size: 36, color: Color(0xFF64748B)),
          const SizedBox(height: 8),
          Text(
            busy ? 'Loading…' : 'No photos or videos yet',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text('Tap Upload Photos, Upload Videos, or Record Video to add media.'),
        ],
      ),
    );
  }
}

/* =========================
   Fullscreen Viewers
   ========================= */

class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({super.key, required this.bytes});
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.sourcePath});
  final String sourcePath; // file path (mobile/desktop) or blob/data URL (web)

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final controller = kIsWeb
          ? VideoPlayerController.networkUrl(Uri.parse(widget.sourcePath))
          : VideoPlayerController.file(File(widget.sourcePath));
      await controller.initialize();
      controller.setLooping(true);
      setState(() => _controller = controller);
      await controller.play();
    } catch (e) {
      setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Video', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _error
            ? const Text('Failed to load video', style: TextStyle(color: Colors.white))
            : (_controller == null || !_controller!.value.isInitialized)
                ? const CircularProgressIndicator()
                : AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio == 0
                        ? 16 / 9
                        : _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
      ),
      floatingActionButton: (_controller != null && _controller!.value.isInitialized)
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}

/* =========================
   Contact
   ========================= */

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isNarrow = w < 950;
    const rightMinHeight = 340.0;

    return _SectionShell(
      title: 'Contact Us',
      subtitle: 'We\'ll call you back for site visits & details.',
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContactFormCard(formKey: _formKey, name: _name, phone: _phone, message: _message),
                const SizedBox(height: 16),
                const _ContactInfoCard(minHeight: rightMinHeight),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _ContactFormCard(formKey: _formKey, name: _name, phone: _phone, message: _message)),
                const SizedBox(width: 16),
                const Expanded(child: _ContactInfoCard(minHeight: rightMinHeight)),
              ],
            ),
    );
  }
}

class _ContactFormCard extends StatelessWidget {
  const _ContactFormCard({
    required this.formKey,
    required this.name,
    required this.phone,
    required this.message,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController message;

  Future<void> _sendWhatsAppMessage(BuildContext context) async {
    final nameText = name.text.trim();
    final phoneText = phone.text.trim();
    final messageText = message.text.trim();
    
    // Create WhatsApp message
    final whatsappMessage = "New Contact Form Submission:\n\nName: $nameText\nPhone: $phoneText\nMessage: ${messageText.isNotEmpty ? messageText : 'No message provided'}";
    
    // WhatsApp URL with phone number and pre-filled message
    final whatsappUrl = Uri.parse(
      'https://wa.me/919849496057?text=${Uri.encodeComponent(whatsappMessage)}'
    );
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        // Clear form after successful launch
        name.clear();
        phone.clear();
        message.clear();
        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening WhatsApp to send your message!')),
          );
        }
      } else {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp. Please try again or call directly.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 10) ? 'Enter a valid phone number' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: message,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      _sendWhatsAppMessage(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A), // Green color
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({required this.minHeight});
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.all(16),
        child: const Column(
          children: [
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('+91 8978347841'),
              subtitle: Text('Call / WhatsApp'),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Vinukonda, Palnadu District'),
              subtitle: Text('Office near Vennela Supermarket'),
            ),
            SizedBox(height: 12),
            SizedBox(height: 150, child: _MapPlaceholder()),
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('Map: Vinukonda (embed later)'),
      ),
    );
  }
}

/* =========================
   Footer
   ========================= */

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  static final Uri _youtubeUri = Uri.parse(
    'https://youtube.com/@bejjamsadvinreddy?si=0NrPx5jHptGK0nTK',
  );

  Future<void> _openYouTube() async {
    if (!await launchUrl(_youtubeUri, mode: LaunchMode.externalApplication)) {
      await launchUrl(_youtubeUri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    const year = '2025';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('© $year Vinukonda Properties'),
                  const Text('All Rights Reserved'),
                  TextButton.icon(
                    onPressed: _openYouTube,
                    
                    icon: const Icon(Icons.ondemand_video),
                    label: const Text('Follow us on YouTube'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   Shared shells & helpers
   ========================= */

class _SectionShell extends StatelessWidget {
  const _SectionShell({super.key, required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final pad = w < 800 ? 16.0 : 24.0;

    return Container(
      padding: EdgeInsets.fromLTRB(pad, 36, pad, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!),
              ],
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class SectionAnchor extends StatelessWidget {
  const SectionAnchor({required this.anchorKey, required this.child, super.key});
  final Key anchorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(key: anchorKey, child: child);
}

/* =========================
   Scroll-to-section controller
   ========================= */

enum _SectionTarget { hero, featured, about, categories, gallery, contact }

class _SectionsController {
  final heroKey = GlobalKey();
  final featuredKey = GlobalKey();
  final aboutKey = GlobalKey();
  final categoriesKey = GlobalKey();
  final galleryKey = GlobalKey();
  final contactKey = GlobalKey();

  void scrollTo(_SectionTarget t, ScrollController controller) {
    BuildContext? ctx;
    switch (t) {
      case _SectionTarget.hero:
        ctx = heroKey.currentContext;
        break;
      case _SectionTarget.featured:
        ctx = featuredKey.currentContext;
        break;
      case _SectionTarget.about:
        ctx = aboutKey.currentContext;
        break;
      case _SectionTarget.categories:
        ctx = categoriesKey.currentContext;
        break;
      case _SectionTarget.gallery:
        ctx = galleryKey.currentContext;
        break;
      case _SectionTarget.contact:
        ctx = contactKey.currentContext;
        break;
    }
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }
}

/* =========================
   Data
   ========================= */

class Property {
  final String title;
  final String type;
  final String location;
  final String area;
  final String price;
  final String? imageUrl;

  Property({
    required this.title,
    required this.type,
    required this.location,
    required this.area,
    required this.price,
    this.imageUrl,
  });
}

final _sampleProperties = <Property>[
  Property(
    title: '2BHK House near Bus Stand',
    type: 'House',
    location: 'Vinukonda',
    area: '1200 sft',
    price: '₹45L',
    imageUrl: 'https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=1200',
  ),
  Property(
    title: 'Residential Plot – Bypass Road',
    type: 'Site',
    location: 'Vinukonda',
    area: '200 sq.yds',
    price: '₹28L',
    imageUrl: 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=1200',
  ),
  Property(
    title: 'Commercial Plot – Main Road',
    type: 'Commercial',
    location: 'Vinukonda',
    area: '300 sq.yds',
    price: '₹60L',
    imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=1200',
  ),
];