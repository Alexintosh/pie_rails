# == Schema Information
#
# Table name: etfs
#
#  id              :bigint           not null, primary key
#  cca_id          :bigint           not null
#  run_date        :date             not null
#  ticker          :string(32)       not null
#  fund_name       :string(128)      not null
#  forecast_e      :decimal(8, 4)
#  forecast_s      :decimal(8, 4)
#  forecast_g      :decimal(8, 4)
#  esg_performance :decimal(8, 4)
#  alpha           :decimal(10, 6)
#  benchmark       :decimal(10, 6)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Etf < ApplicationRecord
  ESG_WEIGHT = 0.8
  FORECAST_WEIGHT = 0.15
  PERFORMANCE_WEIGHT = 0.05
  EPSILON = 0.01
  
  validates_presence_of :ticker, :fund_name
  validates_length_of :ticker, :maximum => 32
  validates_length_of :fund_name, :maximum => 128
  
  validates_numericality_of :forecast_e, :forecast_s, :forecast_g, :alpha, :esg_performance, :alpha, :benchmark
  
  def self.find_best(setting, top_n=100)
    min_e, max_e = Etf.all.minimum(:forecast_e), Etf.all.maximum(:forecast_e)
    min_s, max_s = Etf.all.minimum(:forecast_s), Etf.all.maximum(:forecast_s)
    min_g, max_g = Etf.all.minimum(:forecast_g), Etf.all.maximum(:forecast_g)
    min_alpha, max_alpha = Etf.all.minimum(:alpha), Etf.all.maximum(:alpha)
    min_perf, max_perf = Etf.all.minimum(:benchmark), Etf.all.maximum(:benchmark)
    e_range = max_e - min_e
    s_range = max_s - min_s
    g_range = max_g - min_g
    alpha_range = max_alpha - min_alpha
    perf_range = max_perf - min_perf
    
    # avoid division by zero
    e_range = EPSILON if 0 == e_range
    s_range = EPSILON if 0 == s_range
    g_range = EPSILON if 0 == g_range
    alpha_range = EPSILON if 0 == alpha_range
    perf_range = EPSILON if 0 == perf_range
    
    # 80% weight on ESG, 15% predicted alpha, 5% past performance
    # priorities are percentages, so max score is 100.    
    Etf.all.sort_by { |etf| ((etf.forecast_e - min_e)/e_range * setting.e_priority +
                             (etf.forecast_s - min_s)/s_range * setting.s_priority +
                             (etf.forecast_g - min_g)/g_range * setting.g_priority) * ESG_WEIGHT + 
                             (etf.alpha - min_alpha)/alpha_range * 100 * FORECAST_WEIGHT * 
                             (etf.benchmark - min_perf)/perf_range * 100 * PERFORMANCE_WEIGHT}[0..top_n-1].reverse
  end
end
