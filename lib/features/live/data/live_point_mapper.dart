import '../../../domain/entities/live_point.dart';
import 'live_point_dto.dart';

/// Maps between [LivePointDto] and [LivePoint].
class LivePointMapper {
  LivePointMapper._();

  static LivePoint toDomain(LivePointDto dto) => LivePoint(
        at: DateTime.fromMillisecondsSinceEpoch(dto.at),
        powerW: dto.powerW,
      );

  static LivePointDto fromDomain(LivePoint p) => LivePointDto(
        at: p.at.millisecondsSinceEpoch,
        powerW: p.powerW,
      );
}
