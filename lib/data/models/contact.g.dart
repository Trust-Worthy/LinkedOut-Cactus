// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContactCollection on Isar {
  IsarCollection<Contact> get contacts => this.collection();
}

const ContactSchema = CollectionSchema(
  name: r'Contact',
  id: 342568039478732666,
  properties: {
    r'addressLabel': PropertySchema(
      id: 0,
      name: r'addressLabel',
      type: IsarType.string,
    ),
    r'company': PropertySchema(
      id: 1,
      name: r'company',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 2,
      name: r'email',
      type: IsarType.string,
    ),
    r'embedding': PropertySchema(
      id: 3,
      name: r'embedding',
      type: IsarType.doubleList,
    ),
    r'eventName': PropertySchema(
      id: 4,
      name: r'eventName',
      type: IsarType.string,
    ),
    r'followUpScheduledFor': PropertySchema(
      id: 5,
      name: r'followUpScheduledFor',
      type: IsarType.dateTime,
    ),
    r'instagram': PropertySchema(
      id: 6,
      name: r'instagram',
      type: IsarType.string,
    ),
    r'isEventMode': PropertySchema(
      id: 7,
      name: r'isEventMode',
      type: IsarType.bool,
    ),
    r'isFollowUpCompleted': PropertySchema(
      id: 8,
      name: r'isFollowUpCompleted',
      type: IsarType.bool,
    ),
    r'lastInteractedAt': PropertySchema(
      id: 9,
      name: r'lastInteractedAt',
      type: IsarType.dateTime,
    ),
    r'latitude': PropertySchema(
      id: 10,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'linkedin': PropertySchema(
      id: 11,
      name: r'linkedin',
      type: IsarType.string,
    ),
    r'longitude': PropertySchema(
      id: 12,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'metAt': PropertySchema(
      id: 13,
      name: r'metAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 15,
      name: r'notes',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(
      id: 16,
      name: r'phone',
      type: IsarType.string,
    ),
    r'rawScannedText': PropertySchema(
      id: 17,
      name: r'rawScannedText',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 18,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 19,
      name: r'title',
      type: IsarType.string,
    ),
    r'twitter': PropertySchema(
      id: 20,
      name: r'twitter',
      type: IsarType.string,
    )
  },
  estimateSize: _contactEstimateSize,
  serialize: _contactSerialize,
  deserialize: _contactDeserialize,
  deserializeProp: _contactDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _contactGetId,
  getLinks: _contactGetLinks,
  attach: _contactAttach,
  version: '3.1.0+1',
);

int _contactEstimateSize(
  Contact object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.addressLabel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.company;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.email;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.embedding;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.eventName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.instagram;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.linkedin;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.phone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rawScannedText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.tags;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.twitter;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _contactSerialize(
  Contact object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.addressLabel);
  writer.writeString(offsets[1], object.company);
  writer.writeString(offsets[2], object.email);
  writer.writeDoubleList(offsets[3], object.embedding);
  writer.writeString(offsets[4], object.eventName);
  writer.writeDateTime(offsets[5], object.followUpScheduledFor);
  writer.writeString(offsets[6], object.instagram);
  writer.writeBool(offsets[7], object.isEventMode);
  writer.writeBool(offsets[8], object.isFollowUpCompleted);
  writer.writeDateTime(offsets[9], object.lastInteractedAt);
  writer.writeDouble(offsets[10], object.latitude);
  writer.writeString(offsets[11], object.linkedin);
  writer.writeDouble(offsets[12], object.longitude);
  writer.writeDateTime(offsets[13], object.metAt);
  writer.writeString(offsets[14], object.name);
  writer.writeString(offsets[15], object.notes);
  writer.writeString(offsets[16], object.phone);
  writer.writeString(offsets[17], object.rawScannedText);
  writer.writeStringList(offsets[18], object.tags);
  writer.writeString(offsets[19], object.title);
  writer.writeString(offsets[20], object.twitter);
}

Contact _contactDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Contact(
    addressLabel: reader.readStringOrNull(offsets[0]),
    company: reader.readStringOrNull(offsets[1]),
    email: reader.readStringOrNull(offsets[2]),
    embedding: reader.readDoubleList(offsets[3]),
    eventName: reader.readStringOrNull(offsets[4]),
    followUpScheduledFor: reader.readDateTimeOrNull(offsets[5]),
    instagram: reader.readStringOrNull(offsets[6]),
    isEventMode: reader.readBoolOrNull(offsets[7]) ?? false,
    isFollowUpCompleted: reader.readBoolOrNull(offsets[8]) ?? false,
    latitude: reader.readDoubleOrNull(offsets[10]),
    linkedin: reader.readStringOrNull(offsets[11]),
    longitude: reader.readDoubleOrNull(offsets[12]),
    metAt: reader.readDateTime(offsets[13]),
    name: reader.readString(offsets[14]),
    notes: reader.readStringOrNull(offsets[15]),
    phone: reader.readStringOrNull(offsets[16]),
    rawScannedText: reader.readStringOrNull(offsets[17]),
    tags: reader.readStringList(offsets[18]),
    title: reader.readStringOrNull(offsets[19]),
    twitter: reader.readStringOrNull(offsets[20]),
  );
  object.id = id;
  object.lastInteractedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _contactDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleList(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringList(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _contactGetId(Contact object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contactGetLinks(Contact object) {
  return [];
}

void _contactAttach(IsarCollection<dynamic> col, Id id, Contact object) {
  object.id = id;
}

extension ContactQueryWhereSort on QueryBuilder<Contact, Contact, QWhere> {
  QueryBuilder<Contact, Contact, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhere> anyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'name'),
      );
    });
  }
}

extension ContactQueryWhere on QueryBuilder<Contact, Contact, QWhereClause> {
  QueryBuilder<Contact, Contact, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> nameGreaterThan(
    String name, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [name],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> nameLessThan(
    String name, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [],
        upper: [name],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> nameBetween(
    String lowerName,
    String upperName, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [lowerName],
        includeLower: includeLower,
        upper: [upperName],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> nameStartsWith(
      String NamePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [NamePrefix],
        upper: ['$NamePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [''],
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterWhereClause> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'name',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'name',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'name',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'name',
              upper: [''],
            ));
      }
    });
  }
}

extension ContactQueryFilter
    on QueryBuilder<Contact, Contact, QFilterCondition> {
  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addressLabel',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      addressLabelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addressLabel',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addressLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addressLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> addressLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addressLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      addressLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addressLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'company',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'company',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'company',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'company',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'company',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> companyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'company',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embedding',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embedding',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      embeddingElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      embeddingElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embedding',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      embeddingLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> embeddingLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eventName',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eventName',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventName',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> eventNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventName',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      followUpScheduledForIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'followUpScheduledFor',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      followUpScheduledForIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'followUpScheduledFor',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      followUpScheduledForEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followUpScheduledFor',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      followUpScheduledForGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'followUpScheduledFor',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      followUpScheduledForLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'followUpScheduledFor',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      followUpScheduledForBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'followUpScheduledFor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'instagram',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'instagram',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'instagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'instagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'instagram',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'instagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'instagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'instagram',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'instagram',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'instagram',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> instagramIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'instagram',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> isEventModeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEventMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      isFollowUpCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFollowUpCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> lastInteractedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastInteractedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      lastInteractedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastInteractedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      lastInteractedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastInteractedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> lastInteractedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastInteractedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> latitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> latitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> latitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> latitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> latitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> latitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedin',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedin',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'linkedin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'linkedin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'linkedin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'linkedin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedin',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> linkedinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'linkedin',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> longitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> longitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> longitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> longitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> longitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> longitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> metAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> metAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> metAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> metAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> rawScannedTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rawScannedText',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      rawScannedTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rawScannedText',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> rawScannedTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawScannedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      rawScannedTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawScannedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> rawScannedTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawScannedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> rawScannedTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawScannedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      rawScannedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawScannedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> rawScannedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawScannedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> rawScannedTextContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawScannedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> rawScannedTextMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawScannedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      rawScannedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawScannedText',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      rawScannedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawScannedText',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'twitter',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'twitter',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'twitter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'twitter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'twitter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'twitter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'twitter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'twitter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'twitter',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'twitter',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'twitter',
        value: '',
      ));
    });
  }

  QueryBuilder<Contact, Contact, QAfterFilterCondition> twitterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'twitter',
        value: '',
      ));
    });
  }
}

extension ContactQueryObject
    on QueryBuilder<Contact, Contact, QFilterCondition> {}

extension ContactQueryLinks
    on QueryBuilder<Contact, Contact, QFilterCondition> {}

extension ContactQuerySortBy on QueryBuilder<Contact, Contact, QSortBy> {
  QueryBuilder<Contact, Contact, QAfterSortBy> sortByAddressLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressLabel', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByAddressLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressLabel', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByCompany() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'company', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByCompanyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'company', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByEventName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByEventNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByFollowUpScheduledFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpScheduledFor', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy>
      sortByFollowUpScheduledForDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpScheduledFor', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByInstagram() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instagram', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByInstagramDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instagram', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByIsEventMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEventMode', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByIsEventModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEventMode', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByIsFollowUpCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFollowUpCompleted', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByIsFollowUpCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFollowUpCompleted', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByLastInteractedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractedAt', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByLastInteractedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractedAt', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByLinkedin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedin', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByLinkedinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedin', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByMetAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metAt', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByMetAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metAt', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByRawScannedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawScannedText', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByRawScannedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawScannedText', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByTwitter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'twitter', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> sortByTwitterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'twitter', Sort.desc);
    });
  }
}

extension ContactQuerySortThenBy
    on QueryBuilder<Contact, Contact, QSortThenBy> {
  QueryBuilder<Contact, Contact, QAfterSortBy> thenByAddressLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressLabel', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByAddressLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addressLabel', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByCompany() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'company', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByCompanyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'company', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByEventName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByEventNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByFollowUpScheduledFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpScheduledFor', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy>
      thenByFollowUpScheduledForDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpScheduledFor', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByInstagram() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instagram', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByInstagramDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'instagram', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByIsEventMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEventMode', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByIsEventModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEventMode', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByIsFollowUpCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFollowUpCompleted', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByIsFollowUpCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFollowUpCompleted', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByLastInteractedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractedAt', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByLastInteractedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastInteractedAt', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByLinkedin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedin', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByLinkedinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedin', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByMetAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metAt', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByMetAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metAt', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByRawScannedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawScannedText', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByRawScannedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawScannedText', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByTwitter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'twitter', Sort.asc);
    });
  }

  QueryBuilder<Contact, Contact, QAfterSortBy> thenByTwitterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'twitter', Sort.desc);
    });
  }
}

extension ContactQueryWhereDistinct
    on QueryBuilder<Contact, Contact, QDistinct> {
  QueryBuilder<Contact, Contact, QDistinct> distinctByAddressLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addressLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByCompany(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'company', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByEmbedding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embedding');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByEventName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByFollowUpScheduledFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'followUpScheduledFor');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByInstagram(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'instagram', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByIsEventMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEventMode');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByIsFollowUpCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFollowUpCompleted');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByLastInteractedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastInteractedAt');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByLinkedin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByMetAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metAt');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByRawScannedText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawScannedText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Contact, Contact, QDistinct> distinctByTwitter(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'twitter', caseSensitive: caseSensitive);
    });
  }
}

extension ContactQueryProperty
    on QueryBuilder<Contact, Contact, QQueryProperty> {
  QueryBuilder<Contact, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> addressLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addressLabel');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> companyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'company');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<Contact, List<double>?, QQueryOperations> embeddingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embedding');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> eventNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventName');
    });
  }

  QueryBuilder<Contact, DateTime?, QQueryOperations>
      followUpScheduledForProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'followUpScheduledFor');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> instagramProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'instagram');
    });
  }

  QueryBuilder<Contact, bool, QQueryOperations> isEventModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEventMode');
    });
  }

  QueryBuilder<Contact, bool, QQueryOperations> isFollowUpCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFollowUpCompleted');
    });
  }

  QueryBuilder<Contact, DateTime, QQueryOperations> lastInteractedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastInteractedAt');
    });
  }

  QueryBuilder<Contact, double?, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> linkedinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedin');
    });
  }

  QueryBuilder<Contact, double?, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<Contact, DateTime, QQueryOperations> metAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metAt');
    });
  }

  QueryBuilder<Contact, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> rawScannedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawScannedText');
    });
  }

  QueryBuilder<Contact, List<String>?, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Contact, String?, QQueryOperations> twitterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'twitter');
    });
  }
}
