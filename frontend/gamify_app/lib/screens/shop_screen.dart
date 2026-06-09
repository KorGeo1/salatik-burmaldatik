import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

// ─── Data model ──────────────────────────────────────────────────────────────

class ShopItem {
  final String id;
  final String emoji;
  final String name;
  final String description;
  final int price;
  final String tag;

  const ShopItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.price,
    this.tag = '',
  });
}

const _items = [
  ShopItem(
    id: 'tshirt_white',
    emoji: '👕',
    name: 'Футболка Classic',
    description: 'Белая футболка с вышитым логотипом',
    price: 1750,
    tag: 'Хит',
  ),
  ShopItem(
    id: 'tshirt_black',
    emoji: '🖤',
    name: 'Футболка Black Edition',
    description: 'Чёрная оверсайз-футболка премиум качества',
    price: 2100,
    tag: 'Новинка',
  ),
  ShopItem(
    id: 'hoodie',
    emoji: '🧥',
    name: 'Худи Signature',
    description: 'Тёплое худи с принтом на спине',
    price: 4450,
    tag: 'Редкий',
  ),
  ShopItem(
    id: 'cap',
    emoji: '🧢',
    name: 'Кепка Snapback',
    description: 'Регулируемая кепка с логотипом',
    price: 1400,
    tag: 'Хит',
  ),
  ShopItem(
    id: 'mug',
    emoji: '☕',
    name: 'Кружка 350мл',
    description: 'Керамическая кружка с принтом',
    price: 190,
    tag: '',
  ),
  ShopItem(
    id: 'bottle',
    emoji: '🍶',
    name: 'Термобутылка',
    description: 'Нержавеющая сталь, 500мл, держит 12 часов',
    price: 460,
    tag: 'Новинка',
  ),
  ShopItem(
    id: 'sticker_pack',
    emoji: '🎨',
    name: 'Стикерпак',
    description: '10 виниловых стикеров с персонажами',
    price: 120,
    tag: '',
  ),
  ShopItem(
    id: 'tote',
    emoji: '🛍️',
    name: 'Шоппер Eco',
    description: 'Хлопковый шоппер 42×38 см',
    price: 160,
    tag: '',
  ),
  ShopItem(
    id: 'notebook',
    emoji: '📓',
    name: 'Блокнот A5',
    description: '96 страниц, твёрдая обложка с логотипом',
    price: 210,
    tag: '',
  ),
  ShopItem(
    id: 'hoodie_zip',
    emoji: '🫰',
    name: 'Толстовка на молнии',
    description: 'Зип-худи с боковыми карманами',
    price: 4750,
    tag: 'Редкий',
  ),
];

// ─── Tag colors ───────────────────────────────────────────────────────────────

Color _tagColor(String tag) {
  switch (tag) {
    case 'Хит':
      return AppTheme.primary;
    case 'Новинка':
      return AppTheme.questGreen;
    case 'Редкий':
      return AppTheme.legendaryPurple;
    default:
      return Colors.transparent;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final Set<String> _purchased = {};

  void _buy(ShopItem item, int coins) {
    if (coins < item.price || _purchased.contains(item.id)) return;
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        item: item,
        coins: coins,
        onConfirm: () {
          context.read<AppState>().spendCoins(item.price);
          setState(() => _purchased.add(item.id));
          Navigator.pop(context);
          _showSuccess(item);
        },
      ),
    );
  }

  void _showSuccess(ShopItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppTheme.questGreen,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Text('✅', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '«${item.name}» добавлен в твои покупки!',
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<AppState>().user.coins;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Магазин мерча',
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.gold.withValues(alpha: 0.35),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 5),
                        Text(
                          '$coins',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Трать монеты на крутой мерч 🔥',
                style: GoogleFonts.manrope(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // ── Grid ──
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  final bought = _purchased.contains(item.id);
                  final canAfford = coins >= item.price;
                  return _ShopCard(
                    item: item,
                    bought: bought,
                    canAfford: canAfford,
                    onTap: () => _buy(item, coins),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shop card ────────────────────────────────────────────────────────────────

class _ShopCard extends StatelessWidget {
  final ShopItem item;
  final bool bought;
  final bool canAfford;
  final VoidCallback onTap;

  const _ShopCard({
    required this.item,
    required this.bought,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: bought ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: bought ? 0.65 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: bought
                ? Border.all(
                    color: AppTheme.questGreen.withValues(alpha: 0.5),
                    width: 1.5)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.055),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji area
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Text(item.emoji,
                          style: const TextStyle(fontSize: 52)),
                    ),
                  ),
                  if (item.tag.isNotEmpty && !bought)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _tagColor(item.tag),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.tag,
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  if (bought)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppTheme.questGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),

              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: GoogleFonts.manrope(
                        fontSize: 10.5,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    bought
                        ? Container(
                            width: double.infinity,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTheme.questGreen.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Куплено',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.questGreen,
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 34,
                            decoration: BoxDecoration(
                              color: canAfford
                                  ? AppTheme.primary
                                  : AppTheme.silver.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '🪙 ${item.price}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: canAfford
                                        ? Colors.white
                                        : AppTheme.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Confirm bottom sheet ─────────────────────────────────────────────────────

class _ConfirmSheet extends StatelessWidget {
  final ShopItem item;
  final int coins;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.item,
    required this.coins,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = coins - item.price;
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textHint.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(item.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: GoogleFonts.manrope(
                fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CostRow(label: 'Стоимость', value: '🪙 ${item.price}'),
                Container(
                    width: 1,
                    height: 28,
                    color: AppTheme.textHint.withValues(alpha: 0.2)),
                _CostRow(label: 'Остаток', value: '🪙 $remaining'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: BorderSide(
                        color: AppTheme.textHint.withValues(alpha: 0.4),
                        width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Отмена',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Купить',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  const _CostRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.manrope(
                fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}