class InvestmentScorecard {
  final double fundamentals;
  final double growth;
  final double valuation;
  final double technicalTrend;
  final double riskScore;
  final double overall;
  final double? peRatio;
  final double? pbRatio;
  final double? roe;
  final double? debtToEquity;

  InvestmentScorecard({
    required this.fundamentals,
    required this.growth,
    required this.valuation,
    required this.technicalTrend,
    required this.riskScore,
    required this.overall,
    this.peRatio,
    this.pbRatio,
    this.roe,
    this.debtToEquity,
  });

  factory InvestmentScorecard.fromJson(Map<String, dynamic> json) {
    return InvestmentScorecard(
      fundamentals: (json['fundamentals'] as num?)?.toDouble() ?? 50.0,
      growth: (json['growth'] as num?)?.toDouble() ?? 50.0,
      valuation: (json['valuation'] as num?)?.toDouble() ?? 50.0,
      technicalTrend: (json['technical_trend'] as num?)?.toDouble() ?? 50.0,
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 50.0,
      overall: (json['overall'] as num?)?.toDouble() ?? 50.0,
      peRatio: (json['pe_ratio'] as num?)?.toDouble(),
      pbRatio: (json['pb_ratio'] as num?)?.toDouble(),
      roe: (json['roe'] as num?)?.toDouble(),
      debtToEquity: (json['debt_to_equity'] as num?)?.toDouble(),
    );
  }
}

class ValidationModel {
  final String modelName;
  final String signal;
  final String direction;
  final double probability;
  final double confidence;
  final bool agreesWithPrimary;
  final String validationNote;

  ValidationModel({
    required this.modelName,
    required this.signal,
    required this.direction,
    required this.probability,
    required this.confidence,
    required this.agreesWithPrimary,
    required this.validationNote,
  });

  factory ValidationModel.fromJson(Map<String, dynamic> json) {
    return ValidationModel(
      modelName: json['model_name'] ?? 'Validation Model',
      signal: json['signal'] ?? 'HOLD',
      direction: json['direction'] ?? 'NEUTRAL',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.5,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      agreesWithPrimary: json['agrees_with_primary'] ?? false,
      validationNote: json['validation_note'] ?? '',
    );
  }
}

class NewsItem {
  final String title;
  final String publisher;
  final String publishedAt;
  final String? url;
  final String sentiment;
  final double sentimentScore;

  NewsItem({
    required this.title,
    required this.publisher,
    required this.publishedAt,
    this.url,
    required this.sentiment,
    required this.sentimentScore,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      publisher: json['publisher'] ?? 'Financial News',
      publishedAt: json['published_at'] ?? '',
      url: json['url'],
      sentiment: json['sentiment'] ?? 'NEUTRAL',
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NewsStudy {
  final String sentimentLabel;
  final double sentimentScore;
  final int totalArticles;
  final String catalystSummary;
  final List<NewsItem> topHeadlines;

  NewsStudy({
    required this.sentimentLabel,
    required this.sentimentScore,
    required this.totalArticles,
    required this.catalystSummary,
    required this.topHeadlines,
  });

  factory NewsStudy.fromJson(Map<String, dynamic> json) {
    return NewsStudy(
      sentimentLabel: json['sentiment_label'] ?? 'NEUTRAL',
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble() ?? 0.0,
      totalArticles: (json['total_articles'] as num?)?.toInt() ?? 0,
      catalystSummary: json['catalyst_summary'] ?? '',
      topHeadlines: (json['top_headlines'] as List<dynamic>?)
              ?.map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class StrategyStudy {
  final String strategyName;
  final String strategyDescription;
  final String timeframePlan;
  final List<String> keyConfluences;
  final String riskManagementRule;
  final String internetStudySource;

  StrategyStudy({
    required this.strategyName,
    required this.strategyDescription,
    required this.timeframePlan,
    required this.keyConfluences,
    required this.riskManagementRule,
    required this.internetStudySource,
  });

  factory StrategyStudy.fromJson(Map<String, dynamic> json) {
    return StrategyStudy(
      strategyName: json['strategy_name'] ?? 'Quantitative Strategy',
      strategyDescription: json['strategy_description'] ?? '',
      timeframePlan: json['timeframe_plan'] ?? '',
      keyConfluences: (json['key_confluences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      riskManagementRule: json['risk_management_rule'] ?? '',
      internetStudySource: json['internet_study_source'] ?? '',
    );
  }
}

class PredictionHistoryItem {
  final String timestamp;
  final String signal;
  final double entryPrice;
  final double target;
  final double stopLoss;
  final String result;
  final double returnPercent;
  final double pnl;

  PredictionHistoryItem({
    required this.timestamp,
    required this.signal,
    required this.entryPrice,
    required this.target,
    required this.stopLoss,
    required this.result,
    required this.returnPercent,
    required this.pnl,
  });

  factory PredictionHistoryItem.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryItem(
      timestamp: json['timestamp'] ?? '',
      signal: json['signal'] ?? 'BUY',
      entryPrice: (json['entry_price'] as num?)?.toDouble() ?? 0.0,
      target: (json['target'] as num?)?.toDouble() ?? 0.0,
      stopLoss: (json['stop_loss'] as num?)?.toDouble() ?? 0.0,
      result: json['result'] ?? 'ACTIVE',
      returnPercent: (json['return_percent'] as num?)?.toDouble() ?? 0.0,
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PredictionHistory {
  final String symbol;
  final String mode;
  final int totalPredictions;
  final double winRate;
  final double profitFactor;
  final List<PredictionHistoryItem> predictions;

  PredictionHistory({
    required this.symbol,
    required this.mode,
    required this.totalPredictions,
    required this.winRate,
    required this.profitFactor,
    required this.predictions,
  });

  factory PredictionHistory.fromJson(Map<String, dynamic> json) {
    return PredictionHistory(
      symbol: json['symbol'] ?? '',
      mode: json['mode'] ?? 'swing',
      totalPredictions: (json['total_predictions'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 78.5,
      profitFactor: (json['profit_factor'] as num?)?.toDouble() ?? 2.5,
      predictions: (json['predictions'] as List<dynamic>?)
              ?.map((e) => PredictionHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Prediction {
  final String symbol;
  final String mode;
  final String timestamp;
  final double currentPrice;
  final String signal;
  final String direction;
  final double probability;
  final double confidence;
  final double accuracyRate;
  final double consensusScore;
  final double target;
  final double stopLoss;
  final double riskRewardRatio;
  final String horizon;
  final String riskLevel;
  final List<String> reasons;
  final List<String> riskFactors;
  final String modelVersion;
  final ValidationModel? validationModel;
  final InvestmentScorecard? investmentScore;
  final NewsStudy? newsStudy;
  final StrategyStudy? strategyStudy;
  final double? historicalWinRate;

  Prediction({
    required this.symbol,
    required this.mode,
    required this.timestamp,
    required this.currentPrice,
    required this.signal,
    required this.direction,
    required this.probability,
    required this.confidence,
    required this.accuracyRate,
    required this.consensusScore,
    required this.target,
    required this.stopLoss,
    required this.riskRewardRatio,
    required this.horizon,
    required this.riskLevel,
    required this.reasons,
    required this.riskFactors,
    required this.modelVersion,
    this.validationModel,
    this.investmentScore,
    this.newsStudy,
    this.strategyStudy,
    this.historicalWinRate,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      symbol: json['symbol'] ?? '',
      mode: json['mode'] ?? 'swing',
      timestamp: json['timestamp'] ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      signal: json['signal'] ?? 'HOLD',
      direction: json['direction'] ?? 'NEUTRAL',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.5,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      accuracyRate: (json['accuracy_rate'] as num?)?.toDouble() ?? 78.0,
      consensusScore: (json['consensus_score'] as num?)?.toDouble() ?? 75.0,
      target: (json['target'] as num?)?.toDouble() ?? 0.0,
      stopLoss: (json['stop_loss'] as num?)?.toDouble() ?? 0.0,
      riskRewardRatio: (json['risk_reward_ratio'] as num?)?.toDouble() ?? 1.0,
      horizon: json['horizon'] ?? '',
      riskLevel: json['risk_level'] ?? 'Medium',
      reasons: (json['reasons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      riskFactors: (json['risk_factors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      modelVersion: json['model_version'] ?? '',
      validationModel: json['validation_model'] != null
          ? ValidationModel.fromJson(json['validation_model'])
          : null,
      investmentScore: json['investment_score'] != null
          ? InvestmentScorecard.fromJson(json['investment_score'])
          : null,
      newsStudy: json['news_study'] != null
          ? NewsStudy.fromJson(json['news_study'])
          : null,
      strategyStudy: json['strategy_study'] != null
          ? StrategyStudy.fromJson(json['strategy_study'])
          : null,
      historicalWinRate: (json['historical_win_rate'] as num?)?.toDouble(),
    );
  }

  bool get isBullish => signal == 'BUY' || signal == 'ACCUMULATE' || direction == 'BULLISH';
  bool get isBearish => signal == 'SELL' || signal == 'AVOID' || direction == 'BEARISH';
}
