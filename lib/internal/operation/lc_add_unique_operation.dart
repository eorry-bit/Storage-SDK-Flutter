part of leancloud_storage;

class _LCAddUniqueOperation extends _LCOperation {
  Set values;

  _LCAddUniqueOperation(Iterable values) {
    this.values = Set.from(values);
  }

  @override
  apply(oldValue, String key) {
    Set result = Set.from(oldValue);
    result = result.union(values);
    return result;
  }

  @override
  encode() {
    return {
      '__op': 'AddUnique',
      'objects': _LCEncoder.encodeList(values.toList())
    };
  }

  @override
  _LCOperation mergeWithPrevious(_LCOperation previousOp) {
    if (previousOp is _LCSetOperation || previousOp is _LCDeleteOperation) {
      return previousOp;
    }
    if (previousOp is _LCAddUniqueOperation) {
      values = values.union(previousOp.values);
      return this;
    }
    throw new ArgumentError('Operation is invalid after previous operation.');
  }

  @override
  List getNewObjectList() {
    return values.toList();
  }
  
}