import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapmoa/schedule/solo_write.dart';
import 'package:mapmoa/schedule/shared_write.dart';
import 'package:mapmoa/schedule/memo_write_page.dart';
import 'package:mapmoa/widgets/custom_bottom_nav_bar.dart';
import 'package:mapmoa/schedule/memo_data.dart'; // ✅ 전역 메모 import

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  bool isPersonalSelected = true;
  bool isSelecting = false;
  Set<int> selectedIndexes = {};

  void _showToast(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0xFF333333),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  Future<void> _addNewMemo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MemoWritePage()),
    );
    if (result != null) {
      setState(() {
        if (isPersonalSelected) {
          globalPersonalMemos.add(result);
        } else {
          globalSharedMemos.add(result);
        }
      });
    }
  }

  Future<void> _editMemo(int index) async {
    if (isSelecting) {
      setState(() {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
        } else {
          selectedIndexes.add(index);
        }
      });
      return;
    }

    final currentMemo =
    isPersonalSelected ? globalPersonalMemos[index] : globalSharedMemos[index];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemoWritePage(
          initialData: {
            'index': index,
            'location': currentMemo['location'],
            'memo': currentMemo['memo'],
            'color': currentMemo['color'],
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isPersonalSelected) {
          globalPersonalMemos[index] = result;
        } else {
          globalSharedMemos[index] = result;
        }
      });
    }
  }

  void _toggleSelectMode() {
    setState(() {
      isSelecting = !isSelecting;
      selectedIndexes.clear();
    });
  }

  void _deleteSelected() {
    setState(() {
      if (isPersonalSelected) {
        globalPersonalMemos.removeWhere((item) =>
            selectedIndexes.contains(globalPersonalMemos.indexOf(item)));
      } else {
        globalSharedMemos.removeWhere((item) =>
            selectedIndexes.contains(globalSharedMemos.indexOf(item)));
      }
      isSelecting = false;
      selectedIndexes.clear();
    });

    _showToast("일정이 삭제되었습니다!");
  }

  void _deleteAll() {
    setState(() {
      if (isPersonalSelected) {
        globalPersonalMemos.clear();
      } else {
        globalSharedMemos.clear();
      }
      isSelecting = false;
      selectedIndexes.clear();
    });

    _showToast("모든 일정이 삭제되었습니다!");
  }

  @override
  Widget build(BuildContext context) {
    final memos = isPersonalSelected ? globalPersonalMemos : globalSharedMemos;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.black, size: 24),
            const SizedBox(width: 8),
            Text(
              isPersonalSelected ? '개인일정' : '공유일정',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: isPersonalSelected ? const Color(0xFFFFA724) : Colors.grey,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      isPersonalSelected = true;
                      isSelecting = false;
                      selectedIndexes.clear();
                    });
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.groups,
                    color: !isPersonalSelected ? const Color(0xFFFFA724) : Colors.grey,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      isPersonalSelected = false;
                      isSelecting = false;
                      selectedIndexes.clear();
                    });
                  },
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    if (value == 'delete_selected') {
                      _toggleSelectMode();
                    } else if (value == 'delete_all') {
                      _deleteAll();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete_selected',
                      child: Center(child: Text('삭제하기')),
                    ),
                    const PopupMenuItem(
                      value: 'delete_all',
                      child: Center(child: Text('모두삭제')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (isSelecting) {
            setState(() {
              isSelecting = false;
              selectedIndexes.clear();
            });
          }
        },
        child: isPersonalSelected
            ? SoloWritePage(
          memos: globalPersonalMemos,
          onMemoTap: _editMemo,
          isSelecting: isSelecting,
          selectedIndexes: selectedIndexes,
        )
            : SharedWritePage(
          memos: globalSharedMemos,
          onMemoTap: _editMemo,
          isSelecting: isSelecting,
          selectedIndexes: selectedIndexes,
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isSelecting
            ? Padding(
          padding: const EdgeInsets.only(bottom: 24, right: 16),
          child: FloatingActionButton.extended(
            onPressed: selectedIndexes.isEmpty ? null : _deleteSelected,
            backgroundColor:
            selectedIndexes.isEmpty ? Colors.grey : const Color(0xFFFFA724),
            label: const Text('삭제', style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        )
            : Padding(
          padding: const EdgeInsets.only(bottom: 24, right: 16),
          child: FloatingActionButton(
            onPressed: _addNewMemo,
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.edit, color: Color(0xFFFFA724)),
          ),
        ),
      ),
    );
  }
}
