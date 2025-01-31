import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) setCurrentPage;

  const Pagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.setCurrentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          IconButton(
            onPressed: currentPage > 1
                ? () => setCurrentPage(currentPage - 1)
                : null,
            icon: const Icon(Icons.arrow_back),
            color: currentPage == 1 ? Colors.grey : Colors.white,
          ),
          // Page Numbers
          for (int i = 1; i <= totalPages; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () => setCurrentPage(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentPage == i
                        ? Color(0xB3000000) // active page background
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$i',
                    style: TextStyle(
                      color: currentPage == i ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          // Next Button
          IconButton(
            onPressed: currentPage < totalPages
                ? () => setCurrentPage(currentPage + 1)
                : null,
            icon: const Icon(Icons.arrow_forward),
            color: currentPage == totalPages ? Colors.grey : Colors.white,
          ),
        ],
      ),
    );
  }
}
