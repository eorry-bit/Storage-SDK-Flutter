import 'package:flutter_test/flutter_test.dart';
import 'package:leancloud_storage/leancloud.dart';

import 'utils.dart';

void main() {
  test('private read and write', () async {
    initNorthChina();
    LCObject account = new LCObject('Account');
    LCACL acl = new LCACL();
    account.acl = acl;
    account['balance'] = 1024;
    await account.save();
    assert(acl.getPublicWriteAccess() == false);
    assert(acl.getPublilcReadAccess() == false);
  });

  test('user read and write', () async {
    initNorthChina();

    await LCUser.login('hello', 'world');
    LCObject account = new LCObject('Account');
    LCACL acl = LCACL.createWithOwner(LCUser.currentUser);
    account.acl = acl;
    account['balance'] = 512;
    await account.save();

    assert(acl.getUserReadAccess(LCUser.currentUser) == true);
    assert(acl.getUserWriteAccess(LCUser.currentUser) == true);

    LCQuery<LCObject> query = new LCQuery('Account');
    LCObject result = await query.get(account.objectId); 
    print(result.objectId);
    assert(result.objectId != null);

    LCUser.logout();
    result = await query.get(account.objectId);
    assert(result == null);
  });

  test('role read and write', () async {
    initNorthChina();
    LCQuery<LCRole> query = LCRole.getQuery();
    LCRole owner = await query.get('5e1440cbfc36ed006add1b8d');
    LCObject account = new LCObject('Account');
    LCACL acl = new LCACL();
    acl.setRoleReadAccess(owner, true);
    acl.setRoleWriteAccess(owner, true);
    account.acl = acl;
    await account.save();
    assert(acl.getRoleReadAccess(owner) == true);
    assert(acl.getRoleWriteAccess(owner) == true);
  });

  test('query', () async {
    initNorthChina();
    await LCUser.login('game', 'play');
    LCQuery<LCObject> query = new LCQuery<LCObject>('Account');
    LCObject account = await query.get('5e144525dd3c13006a8f8de2');
    print(account.objectId);
  });
}