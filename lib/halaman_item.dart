import 'package:flutter/material.dart';
import 'dart:convert';
import 'data.dart';

class HalamanItem extends StatelessWidget {
  final ItemMenu item;

  const HalamanItem(this.item, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7, bottom: 7),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              item.nama,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    item.imageFile.path.startsWith('assets/')
                        ? Image.asset(
                            item.imageFile.path,
                            fit: BoxFit.cover,
                          )
                        : item.imageFile.path.startsWith('http')
                            ? Image.network(
                                item.imageFile.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons
                                      .error); // Placeholder in case of error
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return CircularProgressIndicator();
                                },
                              )
                            : Image.memory(
                                base64Decode(item.imageFile
                                    .path), // Gambar dari BLOB dalam database
                                fit: BoxFit.cover,
                              ),
                    const SizedBox(height: 7),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.deskripsi),
                        const SizedBox(height: 7),
                        Text("Rp ${item.harga}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
