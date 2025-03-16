import 'package:flutter/material.dart';
import '../models/people.dart';
import '../models/chat_session.dart';
import '../components/people_selection_view.dart';
import '../components/chat_conversation_view.dart';
import '../components/left_sidebar.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  List<People> _peoples = [];
  People? _selectedPeople;
  ChatSession? _currentSession;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPeoples();
  }

  // 加载用户列表
  Future<void> _loadPeoples() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final peoples = await _apiService.getPeople();
      setState(() {
        _peoples = peoples;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showError('加载用户列表失败：${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 创建新用户
  Future<void> _createPeople(String name, String relationship) async {
    try {

      setState(() {
        _error = null;
      });

      final newPeople = await _apiService.createPeople(name, relationship);
      setState(() {
        _peoples.add(newPeople);
      });
      _showSuccess('创建用户成功！');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      _showError('创建用户失败：${e.toString()}');
    }
  }

  // 选择用户
  void _selectPeople(People people) async {
    try {
      final session = await _apiService.createSession(people.id!);
      setState(() {
        _selectedPeople = people;
        _currentSession = session;
      });
    } catch (e) {
      _showError('${e.toString()}');
    }
  }

  // 选择会话
  void _selectSession(ChatSession session) {
    setState(() {
      _currentSession = session;
    });
  }

  // 开始新会话
  Future<void> _startNewChat() async {
    if (_selectedPeople == null) return;
    try {
      final session = await _apiService.createSession(_selectedPeople!.id!);
      setState(() {
        _currentSession = session;
      });
    } catch (e) {
      _showError('${e.toString()}');
    }
  }

  // 返回选择人界面
  Future<void> _backToPeopleSelection() async {
    if (_currentSession != null) {
      try {
        // 检查当前会话是否为空
        final messageCount = await _apiService.getSessionMessageCount(
          _currentSession!.id,
        );
        if (messageCount == 0) {
          // 如果会话为空，删除它
          await _apiService.deleteSession(_currentSession!.id);
          print('${_currentSession!.id}');
        }
      } catch (e) {
        print('${e.toString()}');
      }
    }

    // 确保在所有操作完成后再更新状态
    setState(() {
      _selectedPeople = null;
      _currentSession = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar:
          _selectedPeople != null
              ? AppBar(
                backgroundColor: Colors.grey[850],
                elevation: 1,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _backToPeopleSelection,
                  tooltip: '',
                ),
                title: Text(
                  '${_selectedPeople!.name}',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : null,
      body: Row(
        children: [
          if (_selectedPeople != null)
            Container(
              width: 300,
              child: LeftSidebar(
                currentPeople: _selectedPeople!,
                onSessionSelected: _selectSession,
                onNewChat: _startNewChat,
              ),
            ),
          Expanded(
            child:
                _selectedPeople == null || _currentSession == null
                    ? _buildPeopleSelection()
                    : ChatConversationView(
                      people: _selectedPeople!,
                      session: _currentSession!,
                    ),

          ),
        ),
        child: Row(
          children: [
            Expanded(
              child:
                  selectedPeople == null
                      ? PeopleSelectionView(
                        peoples: peoples,
                        showAddUserForm: _showAddUserForm,
                        onPeopleSelected: _selectPeople,
                        onShowAddForm: () {
                          setState(() {
                            _showAddUserForm = true;
                          });
                        },
                        onCreatePeople: _createPeople,
                      )
                      : ChatConversationView(
                        messages: messages,
                        chatController: _chatController,
                        onSendMessage: _sendMessage,
                        people: selectedPeople!,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleSelection() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('加载中...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text('出错了', style: TextStyle(color: Colors.red, fontSize: 18)),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.red[300]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPeoples,
              icon: Icon(Icons.refresh),
              label: Text('重试'),
            ),
          ],
        ),
      );
    }

    return PeopleSelectionView(
      peoples: _peoples,
      showAddUserForm: false,
      onPeopleSelected: _selectPeople,
      onShowAddForm: () {},
      onCreatePeople: _createPeople,
    );
  }
}
