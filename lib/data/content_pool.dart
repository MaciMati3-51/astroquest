import '../models/cosmic_element.dart';

/// エレメントごとのCosmic Status文言プール（日付シードで決定的に選択）。
const Map<CosmicElement, List<String>> cosmicStatusPool = {
  CosmicElement.fire: [
    '本日は火星の影響大：集中力が高まるが肩が凝りやすい日。',
    '炎のエネルギーが漲る一日。ただし燃費に注意。',
    '闘志が湧きやすいタイミング。無理な連戦は避けよ。',
    '瞬発力が上がる星回り。立ち上がる一歩が吉。',
    '情熱の炎が熱すぎる日。こまめな休息で安定を。',
  ],
  CosmicElement.earth: [
    '土星が安定をもたらす日。地に足をつけて動くと吉。',
    '堅実な流れ。小さな積み重ねが後に効いてくる。',
    '体が重く感じやすい星回り。軽い伸びで巡りを良くせよ。',
    '着実に前進できる日。焦らず一歩ずつ。',
    '大地のエネルギーが安定を後押し。姿勢を正すと運気アップ。',
  ],
  CosmicElement.air: [
    '風の流れが速い日。思考は冴えるが、体は置き去りになりがち。',
    '軽やかな気運。深呼吸で頭も体もクリアに。',
    'アイデアが巡る日。血流も巡らせるとさらに冴える。',
    '風向きが変わりやすい星回り。柔軟に、軽く動け。',
    '空気が澄む日。肩の力を抜くと運気が通りやすい。',
  ],
  CosmicElement.water: [
    '月の影響で感情が揺れやすい日。水分補給で心も整う。',
    '静かな流れの日。深く呼吸すると調子が整う。',
    '直感が冴える星回り。体をゆるめると流れが良くなる。',
    '水のエネルギーが滞りやすい日。小さな動きで巡らせよ。',
    '穏やかな一日。無理せず、流れに身を任せて。',
  ],
};

/// エレメントごとのバフ名プール（Buff Missionの成果として付与される表現）。
const Map<CosmicElement, List<String>> buffNamePool = {
  CosmicElement.fire: ['エイム精度+10%', '反応速度+12%', '闘志+15%'],
  CosmicElement.earth: ['スタミナ+15%', '防御力+10%', '安定感+12%'],
  CosmicElement.air: ['集中力+10%', '思考速度+12%', '判断力+10%'],
  CosmicElement.water: ['回復力+10%', '直感+12%', 'メンタル耐性+10%'],
};

String pickCosmicStatus(CosmicElement element, DateTime date) {
  final pool = cosmicStatusPool[element]!;
  final seed = date.year * 372 + date.month * 31 + date.day;
  return pool[seed % pool.length];
}

String pickBuffName(CosmicElement element, DateTime date) {
  final pool = buffNamePool[element]!;
  final seed = date.year * 372 + date.month * 31 + date.day;
  return pool[seed % pool.length];
}

int dailySeed(DateTime date) => date.year * 372 + date.month * 31 + date.day;
