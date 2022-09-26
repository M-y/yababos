import 'package:bloc_test/bloc_test.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:yababos/blocs/tag.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/blocs/wallet.dart';
import 'package:yababos/events/tag.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/events/wallet.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/states/tag.dart';
import 'package:yababos/states/transaction.dart';
import 'package:yababos/states/wallet.dart';
import 'package:yababos/views/tag_editor.dart';
import 'package:yababos/views/tags.dart';
import 'package:yababos/views/transaction.dart';
import 'package:yababos/views/transaction_editor.dart';
import 'package:yababos/views/transactions.dart';
import 'package:yababos/views/wallet.dart';
import 'package:yababos/views/wallet_editor.dart';
import 'package:yababos/views/wallet_list.dart';
import 'package:yababos/views/wallets.dart';
import 'l10n_helper.dart';

class TagBlocMock extends MockBloc<TagEvent, TagState> implements TagBloc {}

class WalletBlocMock extends MockBloc<WalletEvent, WalletState>
    implements WalletBloc {}

class TransactionBlocMock extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

void main() {
  group("Tag Editor", () {
    bool isCalled = false;
    Widget tagEditor = L10nHelper.build(TagEditor(
      tag: Tag(name: "Existing tag", color: Colors.green),
      onSave: (tag) => isCalled = true,
      onDelete: (tag) => isCalled = true,
    ));

    testWidgets("Calling onSave method", (widgetTester) async {
      await widgetTester.pumpWidget(tagEditor);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(FloatingActionButton));
      expect(isCalled, true);
      isCalled = false;
    });

    testWidgets("Calling onDelete method", (widgetTester) async {
      await widgetTester.pumpWidget(tagEditor);
      await widgetTester.pumpAndSettle();

      String delete = L10nHelper.getLocalizations().delete;
      await widgetTester.tap(find.descendant(
          of: find.byType(TextButton), matching: find.text(delete)));

      expect(isCalled, true);
      isCalled = false;
    });

    group("New tag / Edit tag behaviour", () {
      Widget newTagWidget = L10nHelper.build(TagEditor(
        tag: Tag(name: ""),
        onSave: (tag) => null,
        isNew: true,
      ));
      Widget editTagWidget = L10nHelper.build(TagEditor(
        tag: Tag(name: "Existing tag", color: Colors.green),
        onSave: (tag) => null,
      ));
      String editTag = L10nHelper.getLocalizations().editTag;
      String newTag = L10nHelper.getLocalizations().newTag;

      testWidgets("Appbar title on edit", (widgetTester) async {
        await widgetTester.pumpWidget(editTagWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text(editTag), findsOneWidget);
        expect(find.text(newTag), findsNothing);
      });

      testWidgets("Appbar title on new", (widgetTester) async {
        await widgetTester.pumpWidget(newTagWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text(newTag), findsOneWidget);
        expect(find.text(editTag), findsNothing);
      });

      testWidgets("Delete button appears on edit", (widgetTester) async {
        await widgetTester.pumpWidget(editTagWidget);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        expect(find.text(delete), findsOneWidget);
      });

      testWidgets("Delete button disappears on new", (widgetTester) async {
        await widgetTester.pumpWidget(newTagWidget);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        expect(find.text(delete), findsNothing);
      });

      testWidgets("Existing tag name on name field", (widgetTester) async {
        await widgetTester.pumpWidget(editTagWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text("Existing tag"), findsOneWidget);
      });

      testWidgets("Existing tag color on color field", (widgetTester) async {
        await widgetTester.pumpWidget(editTagWidget);
        await widgetTester.pumpAndSettle();

        var finder = find
            .ancestor(
              of: find.byKey(Key("pickedColor")),
              matching: find.byType(Container),
            )
            .evaluate();
        Color? c =
            ((finder.first.widget as Container).decoration as BoxDecoration)
                .color;
        expect(c, equals(Colors.green));
      });
    });
  });

  group("Tags", () {
    testWidgets("no tags label", (widgetTester) async {
      final tagBloc = TagBlocMock();
      whenListen<TagState>(
        tagBloc,
        Stream<TagState>.fromIterable([TagLoaded(List.empty())]),
        initialState: TagLoading(),
      );
      await widgetTester.pumpWidget(
        L10nHelper.build(
            BlocProvider<TagBloc>(create: (c) => tagBloc, child: TagsWidget())),
      );
      await widgetTester.pumpAndSettle();

      expect(find.text(L10nHelper.getLocalizations().noTags), findsOneWidget);
    });

    testWidgets("tag cards", (widgetTester) async {
      final tagBloc = TagBlocMock();
      whenListen<TagState>(
        tagBloc,
        Stream<TagState>.fromIterable([
          TagLoaded(List.from([
            Tag(name: "t1"),
            Tag(name: "t2"),
          ]))
        ]),
        initialState: TagLoading(),
      );
      await widgetTester.pumpWidget(
        L10nHelper.build(
            BlocProvider<TagBloc>(create: (c) => tagBloc, child: TagsWidget())),
      );
      await widgetTester.pumpAndSettle();

      expect(find.text("t1"), findsOneWidget);
      expect(find.text("t2"), findsOneWidget);
    });
  });

  group("Transaction Editor", () {
    bool isCalled = false;
    Widget transactionEditor = L10nHelper.build(TransactionEditor(
      transaction: Transaction(
        id: 0,
        amount: 0,
        from: 0,
        to: 0,
        when: DateTime.now(),
      ),
      wallets: List.empty(),
      onSave: (tag) => isCalled = true,
      onDelete: (tag) => isCalled = true,
    ));

    testWidgets("Calling onSave method", (widgetTester) async {
      await widgetTester.pumpWidget(transactionEditor);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(FloatingActionButton));
      expect(isCalled, true);
      isCalled = false;
    });

    testWidgets("Calling onDelete method", (widgetTester) async {
      await widgetTester.pumpWidget(transactionEditor);
      await widgetTester.pumpAndSettle();

      String delete = L10nHelper.getLocalizations().delete;
      await widgetTester.tap(find.descendant(
          of: find.byType(TextButton), matching: find.text(delete)));

      expect(isCalled, true);
      isCalled = false;
    });

    group("New transaction / Edit transaction behaviour", () {
      Widget newTransactionWidget = L10nHelper.build(TransactionEditor(
        transaction: Transaction(
          id: 0,
          amount: 0,
          from: 0,
          to: 0,
          when: DateTime.now(),
        ),
        wallets: List.empty(),
        onSave: (transaction) => null,
        isNew: true,
      ));
      Widget editTransactionWidget = L10nHelper.build(TransactionEditor(
        transaction: Transaction(
          id: 0,
          amount: 0,
          from: 0,
          to: 0,
          when: DateTime.now(),
        ),
        wallets: List.empty(),
        onSave: (transaction) => null,
      ));
      String editTransaction = L10nHelper.getLocalizations().editTransaction;
      String newTransaction = L10nHelper.getLocalizations().newTransaction;

      testWidgets("Appbar title on edit", (widgetTester) async {
        await widgetTester.pumpWidget(editTransactionWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text(editTransaction), findsOneWidget);
        expect(find.text(newTransaction), findsNothing);
      });

      testWidgets("Appbar title on new", (widgetTester) async {
        await widgetTester.pumpWidget(newTransactionWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text(newTransaction), findsOneWidget);
        expect(find.text(editTransaction), findsNothing);
      });

      testWidgets("Delete button appears on edit", (widgetTester) async {
        await widgetTester.pumpWidget(editTransactionWidget);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        expect(find.text(delete), findsOneWidget);
      });

      testWidgets("Delete button disappears on new", (widgetTester) async {
        await widgetTester.pumpWidget(newTransactionWidget);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        expect(find.text(delete), findsNothing);
      });
    });

    group("Form fields", () {
      Transaction transaction = Transaction(
        id: 0,
        amount: 100,
        from: 0,
        to: 1,
        when: DateTime.now(),
        tags: List.from([Tag(name: "t1")]),
        description: "A description",
      );
      Widget transactionEditor = L10nHelper.build(TransactionEditor(
        transaction: transaction,
        wallets: List.from([Wallet(id: 1, name: "1")]),
        onSave: (tag) => null,
      ));

      testWidgets("From", (widgetTester) async {
        await widgetTester.pumpWidget(transactionEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("from"));
        expect(f, findsOneWidget);
        WalletList w = f.evaluate().first.widget as WalletList;
        expect(w.selected, transaction.from);
      });

      testWidgets("To", (widgetTester) async {
        await widgetTester.pumpWidget(transactionEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("to"));
        expect(f, findsOneWidget);
        WalletList w = f.evaluate().first.widget as WalletList;
        expect(w.selected, transaction.to);
      });

      testWidgets("When", (widgetTester) async {
        await widgetTester.pumpWidget(transactionEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("when"));
        expect(f, findsOneWidget);
        DateTimePicker w = f.evaluate().first.widget as DateTimePicker;
        expect(w.initialValue, transaction.when.toIso8601String());
      });

      testWidgets("Amount", (widgetTester) async {
        await widgetTester.pumpWidget(transactionEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("amount"));
        expect(f, findsOneWidget);
        TextFormField w = f.evaluate().first.widget as TextFormField;
        expect(w.initialValue, transaction.amount.toString());
      });

      testWidgets("Tags", (widgetTester) async {
        await widgetTester.pumpWidget(transactionEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("tags"));
        expect(f, findsOneWidget);
        ChipsInput w = f.evaluate().first.widget as ChipsInput;
        expect(w.initialValue, transaction.tags);
      });

      testWidgets("Description", (widgetTester) async {
        await widgetTester.pumpWidget(transactionEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("description"));
        expect(f, findsOneWidget);
        TextFormField w = f.evaluate().first.widget as TextFormField;
        expect(w.initialValue, transaction.description);
      });
    });
  });

  group("Transaction", () {
    Transaction transaction = Transaction(
      id: 0,
      amount: 100,
      from: 0,
      to: 1,
      when: DateTime.now(),
      tags: List.from([Tag(name: "t1"), Tag(name: "t2")]),
      description: "A description",
    );
    Widget transactionWidget = L10nHelper.build(TransactionWidget(
      transaction: transaction,
      wallets: [],
      wallet: Wallet(id: 1),
    ));

    testWidgets("Tags", (widgetTester) async {
      await widgetTester.pumpWidget(transactionWidget);
      await widgetTester.pumpAndSettle();
      expect(find.text(transaction.tags![0].name), findsOneWidget);
      expect(find.text(transaction.tags![1].name), findsOneWidget);
    });

    testWidgets("Description", (widgetTester) async {
      await widgetTester.pumpWidget(transactionWidget);
      await widgetTester.pumpAndSettle();
      expect(find.text(transaction.description!), findsOneWidget);
    });

    testWidgets("Amount", (widgetTester) async {
      await widgetTester.pumpWidget(transactionWidget);
      await widgetTester.pumpAndSettle();
      Text amount = find.byKey(Key("amount")).evaluate().first.widget as Text;
      expect(amount.data, transaction.amount.toString());
    });

    testWidgets("Is expense", (widgetTester) async {
      Transaction transaction = Transaction(
        id: 0,
        amount: 100,
        from: 1,
        to: 0,
        when: DateTime.now(),
        tags: List.from([Tag(name: "t1"), Tag(name: "t2")]),
        description: "A description",
      );
      Widget transactionWidget = L10nHelper.build(TransactionWidget(
        transaction: transaction,
        wallets: [],
        wallet: Wallet(id: 1),
      ));

      await widgetTester.pumpWidget(transactionWidget);
      await widgetTester.pumpAndSettle();
      Text amount = find.byKey(Key("amount")).evaluate().first.widget as Text;
      expect(amount.data, '-' + transaction.amount.toString());
    });
  });

  group("Transactions", () {
    List<Transaction> transactions = List.from([
      Transaction(
        id: 1,
        from: 0,
        to: 1,
        amount: 100,
        when: DateTime.fromMillisecondsSinceEpoch(1663573604000),
      ),
      Transaction(
        id: 2,
        from: 1,
        to: 0,
        amount: 100,
        when: DateTime.fromMillisecondsSinceEpoch(1663487204000),
      ),
      Transaction(
        id: 3,
        from: 1,
        to: 0,
        amount: 100,
        when: DateTime.fromMillisecondsSinceEpoch(1662796004000),
      ),
      Transaction(
        id: 4,
        from: 0,
        to: 1,
        amount: 100,
        when: DateTime.fromMillisecondsSinceEpoch(1662796004000),
      ),
    ]);
    Widget transactionsWidget = L10nHelper.build(TransactionsWidget(
      transactions: transactions,
      wallets: [],
      selectedWallet: Wallet(id: 1),
    ));

    testWidgets("Expansion tiles", (widgetTester) async {
      await widgetTester.pumpWidget(transactionsWidget);
      await widgetTester.pumpAndSettle();

      expect(find.byKey(Key("tile" + DateTime(2022, 9, 19).toString())),
          findsOneWidget);
      expect(find.byKey(Key("tile" + DateTime(2022, 9, 18).toString())),
          findsOneWidget);
      expect(find.byKey(Key("tile" + DateTime(2022, 9, 10).toString())),
          findsOneWidget);
    });

    testWidgets("2022-09-19 has 1 widget", (widgetTester) async {
      await widgetTester.pumpWidget(transactionsWidget);
      await widgetTester.pumpAndSettle();

      Finder expansionTile =
          find.byKey(Key("tile" + DateTime(2022, 9, 19).toString()));

      await widgetTester.tap(expansionTile);
      await widgetTester.pumpAndSettle();

      Finder f = find.descendant(
          of: expansionTile, matching: find.byType(TransactionWidget));
      expect(f, findsOneWidget);
    });

    testWidgets("2022-09-18 has 1 widget", (widgetTester) async {
      await widgetTester.pumpWidget(transactionsWidget);
      await widgetTester.pumpAndSettle();

      Finder expansionTile =
          find.byKey(Key("tile" + DateTime(2022, 9, 18).toString()));

      await widgetTester.tap(expansionTile);
      await widgetTester.pumpAndSettle();

      Finder f = find.descendant(
          of: expansionTile, matching: find.byType(TransactionWidget));
      expect(f, findsOneWidget);
    });

    testWidgets("2022-09-10 has 2 widgets", (widgetTester) async {
      await widgetTester.pumpWidget(transactionsWidget);
      await widgetTester.pumpAndSettle();

      Finder expansionTile =
          find.byKey(Key("tile" + DateTime(2022, 9, 10).toString()));

      await widgetTester.tap(expansionTile);
      await widgetTester.pumpAndSettle();

      Finder f = find.descendant(
          of: expansionTile, matching: find.byType(TransactionWidget));
      expect(f, findsNWidgets(2));
    });

    testWidgets("Day balances", (widgetTester) async {
      await widgetTester.pumpWidget(transactionsWidget);
      await widgetTester.pumpAndSettle();

      Finder f19 = find.descendant(
        of: find.byKey(Key("tile" + DateTime(2022, 9, 19).toString())),
        matching: find.text('100.0'),
      );
      expect(f19, findsOneWidget);

      Finder f18 = find.descendant(
        of: find.byKey(Key("tile" + DateTime(2022, 9, 18).toString())),
        matching: find.text('-100.0'),
      );
      expect(f18, findsOneWidget);

      Finder f10 = find.descendant(
        of: find.byKey(Key("tile" + DateTime(2022, 9, 10).toString())),
        matching: find.text('0.0'),
      );
      expect(f10, findsOneWidget);
    });
  });

  group("Wallet Editor", () {
    bool isCalled = false;
    Wallet wallet = Wallet(
      id: 1,
      name: "Test Wallet",
      amount: 1000000,
      curreny: 'TRY',
    );
    Widget walletEditor = L10nHelper.build(WalletEditor(
      wallet: wallet,
      onSave: (tag) => isCalled = true,
      onDelete: (tag) => isCalled = true,
    ));

    testWidgets("Calling onSave method", (widgetTester) async {
      await widgetTester.pumpWidget(walletEditor);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.byType(FloatingActionButton));
      expect(isCalled, true);
      isCalled = false;
    });

    testWidgets("Calling onDelete method", (widgetTester) async {
      await widgetTester.pumpWidget(walletEditor);
      await widgetTester.pumpAndSettle();

      String delete = L10nHelper.getLocalizations().delete;
      await widgetTester.tap(find.descendant(
          of: find.byType(TextButton), matching: find.text(delete)));

      expect(isCalled, true);
      isCalled = false;
    });

    group("New wallet / Edit wallet behaviour", () {
      Widget newWalletWidget = L10nHelper.build(WalletEditor(
        wallet: Wallet(id: 0),
        onSave: (wallet) => null,
        isNew: true,
      ));
      Widget editWalletWidget = L10nHelper.build(WalletEditor(
        wallet: Wallet(id: 0),
        onSave: (wallet) => null,
      ));
      String editWallet = L10nHelper.getLocalizations().editWallet;
      String newWallet = L10nHelper.getLocalizations().newWallet;

      testWidgets("Appbar title on edit", (widgetTester) async {
        await widgetTester.pumpWidget(editWalletWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text(editWallet), findsOneWidget);
        expect(find.text(newWallet), findsNothing);
      });

      testWidgets("Appbar title on new", (widgetTester) async {
        await widgetTester.pumpWidget(newWalletWidget);
        await widgetTester.pumpAndSettle();

        expect(find.text(newWallet), findsOneWidget);
        expect(find.text(editWallet), findsNothing);
      });

      testWidgets("Delete button appears on edit", (widgetTester) async {
        await widgetTester.pumpWidget(editWalletWidget);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        expect(find.text(delete), findsOneWidget);
      });

      testWidgets("Delete button disappears on new", (widgetTester) async {
        await widgetTester.pumpWidget(newWalletWidget);
        await widgetTester.pumpAndSettle();

        String delete = L10nHelper.getLocalizations().delete;
        expect(find.text(delete), findsNothing);
      });
    });

    group("Form fields", () {
      testWidgets("Name", (widgetTester) async {
        await widgetTester.pumpWidget(walletEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("name"));
        expect(f, findsOneWidget);
        TextFormField w = f.evaluate().first.widget as TextFormField;
        expect(w.initialValue, wallet.name);
      });

      testWidgets("Currency", (widgetTester) async {
        await widgetTester.pumpWidget(walletEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("currency"));
        expect(f, findsOneWidget);
        TextFormField w = f.evaluate().first.widget as TextFormField;
        expect(w.initialValue, wallet.curreny);
      });

      testWidgets("Amount", (widgetTester) async {
        await widgetTester.pumpWidget(walletEditor);
        await widgetTester.pumpAndSettle();

        Finder f = find.byKey(Key("amount"));
        expect(f, findsOneWidget);
        TextFormField w = f.evaluate().first.widget as TextFormField;
        expect(w.initialValue, wallet.amount.toString());
      });
    });
  });

  group("Wallets", () {
    testWidgets("no wallets label", (widgetTester) async {
      final walletBloc = WalletBlocMock();
      whenListen<WalletState>(
        walletBloc,
        Stream<WalletState>.fromIterable(
            [WalletsLoaded(wallets: List.empty())]),
        initialState: WalletLoading(),
      );
      await widgetTester.pumpWidget(
        L10nHelper.build(BlocProvider<WalletBloc>(
            create: (c) => walletBloc, child: WalletsWidget())),
      );
      await widgetTester.pumpAndSettle();

      expect(
          find.text(L10nHelper.getLocalizations().noWallets), findsOneWidget);
    });

    testWidgets("wallet cards", (widgetTester) async {
      final walletBloc = WalletBlocMock();
      whenListen<WalletState>(
        walletBloc,
        Stream<WalletState>.fromIterable([
          WalletsLoaded(
            wallets: List.from([
              Wallet(id: 1, name: "Wallet 1"),
              Wallet(id: 2, name: "Wallet 2"),
            ]),
            selectedWallet: null,
          )
        ]),
        initialState: WalletLoading(),
      );
      await widgetTester.pumpWidget(
        L10nHelper.build(BlocProvider<WalletBloc>(
            create: (c) => walletBloc, child: WalletsWidget())),
      );
      await widgetTester.pumpAndSettle();

      expect(find.text("Wallet 1"), findsOneWidget);
      expect(find.text("Wallet 2"), findsOneWidget);
    });
  });

  group("Wallet List", () {
    int? tapId;
    List<Wallet> wallets = List.from([
      Wallet(id: 1, name: "Wallet 1"),
      Wallet(id: 2, name: "Wallet 2"),
    ]);

    // Should be used in a Scaffold
    // because ListTile widgets require a Material widget ancestor
    Widget walletList = L10nHelper.build(Scaffold(
      body: WalletList(
        wallets: wallets,
        onTap: (id) => tapId = id,
      ),
    ));

    testWidgets("wallets will shown on Listview", (widgetTester) async {
      await widgetTester.pumpWidget(walletList);
      await widgetTester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text(wallets.first.name!), findsOneWidget);
      expect(find.text(wallets.last.name!), findsOneWidget);
    });

    testWidgets("outside doesn't shows up", (widgetTester) async {
      await widgetTester.pumpWidget(walletList);
      await widgetTester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text(L10nHelper.getLocalizations().outside), findsNothing);
    });
    testWidgets("outside shows up", (widgetTester) async {
      Widget walletListWithOutside = L10nHelper.build(Scaffold(
        body: WalletList(
          outside: true,
          wallets: List.empty(),
          onTap: (id) => null,
        ),
      ));

      await widgetTester.pumpWidget(walletListWithOutside);
      await widgetTester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text(L10nHelper.getLocalizations().outside), findsOneWidget);
    });

    testWidgets("tap on second wallet", (widgetTester) async {
      await widgetTester.pumpWidget(walletList);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.ancestor(
          of: find.text(wallets.last.name!), matching: find.byType(ListTile)));
      expect(tapId, 2);
      tapId = null;
    });
    testWidgets("tap on outside", (widgetTester) async {
      Widget walletList = L10nHelper.build(Scaffold(
        body: WalletList(
          outside: true,
          wallets: List.empty(),
          onTap: (id) => tapId = id,
        ),
      ));
      await widgetTester.pumpWidget(walletList);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.ancestor(
          of: find.text(L10nHelper.getLocalizations().outside),
          matching: find.byType(ListTile)));
      expect(tapId, 0);
      tapId = null;
    });

    testWidgets("set outside as selected", (widgetTester) async {
      Widget walletList = L10nHelper.build(Scaffold(
        body: WalletList(
          outside: true,
          wallets: wallets,
          onTap: (id) => null,
          selected: 0,
        ),
      ));
      await widgetTester.pumpWidget(walletList);
      await widgetTester.pumpAndSettle();

      Finder f = find.byWidgetPredicate((widget) =>
          widget is ListTile &&
          widget.selected &&
          (widget.title as Text).data == L10nHelper.getLocalizations().outside);
      expect(f, findsOneWidget);
    });

    testWidgets("set first wallet as selected", (widgetTester) async {
      Widget walletList = L10nHelper.build(Scaffold(
        body: WalletList(
          outside: true,
          wallets: wallets,
          onTap: (id) => null,
          selected: 1,
        ),
      ));
      await widgetTester.pumpWidget(walletList);
      await widgetTester.pumpAndSettle();

      Finder f = find.byWidgetPredicate((widget) =>
          widget is ListTile &&
          widget.selected &&
          (widget.title as Text).data == wallets.first.name);
      expect(f, findsOneWidget);
    });

    testWidgets("set last wallet as selected by tapping", (widgetTester) async {
      Widget walletList = L10nHelper.build(Scaffold(
        body: WalletList(
          outside: true,
          wallets: wallets,
          onTap: (id) => null,
          selected: 1,
        ),
      ));
      await widgetTester.pumpWidget(walletList);
      await widgetTester.pumpAndSettle();

      await widgetTester.tap(find.ancestor(
          of: find.text(wallets.last.name!), matching: find.byType(ListTile)));
      await widgetTester.pumpAndSettle();

      Finder f = find.byWidgetPredicate((widget) =>
          widget is ListTile &&
          widget.selected &&
          (widget.title as Text).data == wallets.last.name);
      expect(f, findsOneWidget);
    });
  });

  group("Wallet", () {
    testWidgets("TransactionWidget count", (widgetTester) async {
      final transactionBloc = TransactionBlocMock();
      List<Transaction> transactions = List.from([
        Transaction(id: 1, from: 0, to: 1, amount: 1, when: DateTime.now()),
        Transaction(id: 2, from: 1, to: 0, amount: 1, when: DateTime.now()),
      ]);
      Wallet wallet = Wallet(id: 1, name: "1");

      whenListen<TransactionState>(
        transactionBloc,
        Stream<TransactionState>.fromIterable([
          WalletTransactionsLoaded(transactions, 0, 1, 1),
        ]),
        initialState: TransactionLoading(),
      );
      await widgetTester.pumpWidget(
        L10nHelper.build(BlocProvider<TransactionBloc>(
          create: (c) => transactionBloc,
          child: WalletWidget(
            month: DateTime.now(),
            wallets: [wallet],
            selectedWallet: wallet,
          ),
        )),
      );
      await widgetTester.pumpAndSettle();

      Finder expansionTile = find.byKey(Key("tile" +
          DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .toString()));

      await widgetTester.tap(expansionTile);
      await widgetTester.pumpAndSettle();

      expect(find.byType(TransactionWidget), findsNWidgets(2));
    });
  });
}
