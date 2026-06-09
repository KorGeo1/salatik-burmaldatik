import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/quest_model.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh when screen opens (post-frame to avoid build-time setState)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshQuests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<AppState>().refreshQuests(),
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                'Квесты',
                style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Выполняй задания и получай награды',
                style: GoogleFonts.manrope(
                    fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              if (state.isLoading && state.quests.isEmpty)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ))
              else if (state.quests.isEmpty)
                _EmptyState()
              else
                ...state.quests.map((q) => _QuestCard(quest: q)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.emoji_events_outlined,
                  size: 64, color: AppTheme.textHint),
              const SizedBox(height: 16),
              Text('Нет доступных квестов',
                  style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
}

class _QuestCard extends StatelessWidget {
  final QuestModel quest;
  const _QuestCard({required this.quest});

  String get _typeLabel => switch (quest.type) {
        QuestType.daily => 'Ежедневный',
        QuestType.weekly => 'Недельный',
        QuestType.special => 'Особый',
      };

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: quest.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(quest.icon, color: quest.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quest.title,
                            style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: quest.color.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _typeLabel,
                            style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: quest.color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quest.description,
                      style: GoogleFonts.manrope(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: quest.progress,
                    minHeight: 8,
                    backgroundColor: AppTheme.background,
                    valueColor: AlwaysStoppedAnimation(quest.color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${quest.current}/${quest.target}',
                style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _badge(icon: Icons.bolt_rounded, color: AppTheme.xpBlue,
                  text: '+${quest.xpReward} XP'),
              const SizedBox(width: 8),
              _badge(emoji: '🪙', color: AppTheme.gold,
                  text: '+${quest.coinReward}'),
              const Spacer(),
              _ActionButton(quest: quest, state: state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(
      {IconData? icon, String? emoji, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 13, height: 1))
          else
            Icon(icon, color: color, size: 14),
          const SizedBox(width: 3),
          Text(text,
              style: GoogleFonts.manrope(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final QuestModel quest;
  final AppState state;
  const _ActionButton({required this.quest, required this.state});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _busy = false;

  Future<void> _claim() async {
    setState(() => _busy = true);
    final ok = await widget.state.claimQuest(widget.quest);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Награда получена: +${widget.quest.xpReward} XP, +${widget.quest.coinReward} 🪙'),
          backgroundColor: AppTheme.questGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quest.claimed) {
      return Text('Получено ✓',
          style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.questGreen));
    }
    final ready = widget.quest.isCompleted;
    return ElevatedButton(
      onPressed: ready && !_busy ? _claim : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: ready ? AppTheme.questGreen : AppTheme.textHint,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child:
                  CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(ready ? 'Забрать' : 'В процессе',
              style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
    );
  }
}
