import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/backup.dart';
import 'package:yababos/events/backup.dart';
import 'package:yababos/states/backup.dart';
import 'package:file_picker/file_picker.dart';

class BackupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<BackupBloc, BackupState>(
        builder: (bcontext, state) {
          if (state is BackupComplete) {
            FilePicker.platform
                .saveFile(
              dialogTitle: 'Please select an output file:',
              fileName: 'export.csv',
            )
                .then((fileName) {
              if (fileName != null) {
                File file = File(fileName);
                file.writeAsString(state.csv);
              }
            });
          }
          if (state is BackupLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.count.toString() + ' transactions loaded.'),
            ));
          }
          return Center(
            child: Column(
              children: [
                TextButton(
                  onPressed: () =>
                      BlocProvider.of<BackupBloc>(context)..add(BackupCreate()),
                  child: Text('Export'),
                ),
                TextButton(
                  onPressed: () {
                    FilePicker.platform.pickFiles().then((result) {
                      File file = File(result.files.single.path);
                      file.readAsString().then((csv) =>
                          BlocProvider.of<BackupBloc>(context)
                            ..add(BackupLoad(csv)));
                    });
                  },
                  child: Text('Import'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
