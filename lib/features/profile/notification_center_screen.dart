import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Tab> _tabs = const [
    Tab(icon: Icon(Icons.thumb_up), text: 'Likes'),
    Tab(icon: Icon(Icons.favorite), text: 'Matches'),
    Tab(icon: Icon(Icons.message), text: 'Messages'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildNotificationList() {
    List<Map<String, String>> notifications = [];

    if (_currentIndex == 0) { // Likes
      notifications = [
        {'user': 'Sarah K.', 'time': '2h ago', 'type': 'liked your photo'},
        {'user': 'David B.', 'time': '5h ago', 'type': 'liked you'},
        {'user': 'Aminata', 'time': '1d ago', 'type': 'super liked'},
      ];
    } else if (_currentIndex == 1) { // Matches
      notifications = [
        {'user': 'Sarah K.', 'time': '3h ago', 'type': 'You matched! Say hello'},
        {'user': 'Aminata', 'time': '1d ago', 'type': 'New match! Mutual like'},
      ];
    } else { // Messages
      notifications = [
        {'user': 'Sarah K.', 'time': '1m ago', 'type': 'New message: Hey! 👋'},
        {'user': 'David B.', 'time': '4h ago', 'type': '2 new messages'},
        {'user': 'Aminata', 'time': '6h ago', 'type': 'Replied to your photo'},
      ];
    }

    return notifications.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_off, size: 64, color: SawaLoveTheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('No ${_tabs[_currentIndex].text}', style: Theme.of(context).textTheme.headlineSmall),
                Text('Turn on notifications in settings', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: SawaLoveTheme.onSurfaceVariant)),
              ],
            ),
          )
        : ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: SawaLoveTheme.primary.withValues(alpha: 0.2),
                  child: Text(notif['user']![0], style: const TextStyle(color: SawaLoveTheme.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text('${notif['user']}'),
                subtitle: Text(notif['type']!),
                trailing: Text(notif['time']!, style: const TextStyle(color: SawaLoveTheme.onSurfaceVariant, fontSize: 12)),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nav to ${notif['user']}'))),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: SawaLoveTheme.primary,
          unselectedLabelColor: SawaLoveTheme.onSurfaceVariant,
          indicatorColor: SawaLoveTheme.primary,
          tabs: _tabs,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(),
              _buildNotificationList(),
              _buildNotificationList(),
            ],
          ),
        ),
      ),
    );
  }
}

