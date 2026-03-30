/// A launchable app on the Samsung TV.
class TvApp {
  final String id;
  final String label;

  /// Samsung app ID used to launch via POST /api/v2/applications/<id>.
  final String samsungAppId;

  const TvApp({
    required this.id,
    required this.label,
    required this.samsungAppId,
  });
}

/// Default list of well-known Samsung TV apps.
const List<TvApp> defaultTvApps = [
  TvApp(id: 'netflix',    label: 'NETFLIX',     samsungAppId: '3201907018807'),
  TvApp(id: 'canalplus',  label: 'CANAL+',      samsungAppId: '3201606009910'),
  TvApp(id: 'disneyplus', label: 'Disney+',     samsungAppId: '3201901017640'),
  TvApp(id: 'youtube',    label: 'YouTube',     samsungAppId: '111299001912'),
  TvApp(id: 'twitch',     label: 'twitch',      samsungAppId: '3202203026841'),
  TvApp(id: 'primevideo', label: 'prime video', samsungAppId: '3201910019365'),
];

/// HDMI / TV sources available for source switching.
const List<String> defaultTvSources = [
  'HDMI 1',
  'HDMI 2',
  'HDMI 3',
  'HDMI 4',
  'TV',
  'USB',
];
