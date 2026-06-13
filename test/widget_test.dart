import 'package:flutter_test/flutter_test.dart';
import 'package:quickcvpro/features/sop/domain/sop_template.dart';

void main() {
  test('SopTemplate model instantiation test', () {
    const template = SopTemplate(
      id: 'test_id',
      name: 'Test Name',
      description: 'Test Description',
      isPremium: true,
    );

    expect(template.id, 'test_id');
    expect(template.name, 'Test Name');
    expect(template.description, 'Test Description');
    expect(template.isPremium, true);
  });
}
