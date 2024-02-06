import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rollmark/auth.dart';
import 'package:rollmark/dto/form_data.dart';
import 'package:rollmark/module/form_card.dart';

class FormPage extends ConsumerWidget {
  FormPage({super.key});

  final formProvider = StreamProvider<List<FormData>>((ref) {
    final userStream = ref.watch(authProvider);

    if (userStream.value != null) {
      var docRef = FirebaseFirestore.instance.collection('forms');
      return docRef.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return FormData.fromDocument(doc);
        }).toList();
      });
    } else {
      return const Stream.empty();
    }
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          try {
            FirebaseFirestore.instance
                .collection('forms')
                .add(FormData.empty().toDocument())
                .then((value) => GoRouter.of(context).go('/forms/${value.id}'));
          } catch (e) {
            AlertDialog(
              title: const Text('Error'),
              content: Text('Error: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('OK'),
                )
              ],
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ref.watch(formProvider).when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(
                  child: Text('No forms found. Go ahead and create one!'),
                );
              } else {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to form edit page
                        GoRouter.of(context).go('/forms/${data[index].id}');
                      },
                      child: FormCard(formData: data[index]),
                    );
                  },
                );
              }
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) {
              return Center(child: Text('Error: $error'));
            },
          ),
    );
  }
}
