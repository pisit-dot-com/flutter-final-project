import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff4f6fb0),
        foregroundColor: Colors.white,     
        toolbarHeight: 60,                 
        titleSpacing: 10,                  
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: Image.network(
                height: 40, 
              "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f1/Pornhub-logo.svg/3840px-Pornhub-logo.svg.png?utm_source=th.wikipedia.org&utm_campaign=index&utm_content=thumbnail"
              ),
             ),  // โลโก้ (แทนรูปเดิม)
            SizedBox(width: 50),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text("Menu"),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text("Random"),
            ),
            SizedBox(width: 20),
            Container(
              width: 200,
              height: 36,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Search Quizzes users or tags",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [                         
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text("Create Account"),
          ),
          SizedBox(width: 10),            
        ],
      ),
      body: Container(color: Colors.white),
    );
  }
}