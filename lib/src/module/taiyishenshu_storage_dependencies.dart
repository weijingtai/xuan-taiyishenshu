import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

/// Storage ports injected into the taiyishenshu product by the host/assembly.
class TaiyishenshuStorageDependencies {
  const TaiyishenshuStorageDependencies({
    required this.officialSchoolRepo,
    required this.userSchoolRepo,
    required this.deityRepo,
    required this.deityPreferenceRepo,
    required this.recordRepo,
  });

  final SchoolRepository officialSchoolRepo;
  final UserSchoolRepository userSchoolRepo;
  final DeityRepository deityRepo;
  final DeityPreferenceRepository deityPreferenceRepo;
  final TaiyiRecordRepository recordRepo;
}
