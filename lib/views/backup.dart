import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:yababos/blocs/backup.dart';
import 'package:yababos/events/backup.dart';
import 'package:yababos/states/backup.dart';
import 'package:file_picker/file_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<BackupBloc, BackupState>(
        builder: (bcontext, state) {
          if (state is BackupComplete) {
            getTemporaryDirectory().then((Directory tempDir) {
              String filePath = join(tempDir.path, 'export.csv');
              File file = File(filePath);
              file
                  .writeAsString(state.csv)
                  .then((f) => Share.shareFiles([filePath]));
            });
          }
          if (state is BackupLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(state.count.toString() + ' transactions loaded.'),
                )));
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
