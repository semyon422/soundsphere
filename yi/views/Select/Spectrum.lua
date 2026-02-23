local View = require("yi.views.View")
local Colors = require("yi.Colors")

local Spectrum = View + {}

local fft_size = 1024
local fft_array_size = fft_size / 2

local num_bars = 32
local mirror_hz = 3700
local sample_rate = 44100
local bin_per_hz = sample_rate / fft_size
local mirror_bin = math.floor(mirror_hz / bin_per_hz)

local bin_mapping = {}
local gain_curve = {}

local update_interval = 0.016
local update_accumulator = 0
local smoothing_factor = 0.7

local function initMappings()
    local min_bin = 2
    local max_bin = mirror_bin
    
    for i = 1, num_bars do
        local t = (i - 1) / (num_bars - 1)
        local bin = min_bin + (max_bin - min_bin) * (t ^ 1.5)
        bin_mapping[i] = math.floor(bin)
    end
    
    for i = 1, num_bars do
        local t = (i - 1) / (num_bars - 1)
        gain_curve[i] = 2.0 - 1.7 * (t ^ 0.7)
    end
end

function Spectrum:load()
    self.game = self:getGame()
    self.game.previewModel:setFFTSize(fft_size)
    self.values = {}
    self.smoothed_values = {}
    
    initMappings()
    
    for i = 1, num_bars do
        self.values[i] = 0
        self.smoothed_values[i] = 0
    end
end

function Spectrum:update(dt)
    update_accumulator = update_accumulator + dt
    
    while update_accumulator >= update_interval do
        update_accumulator = update_accumulator - update_interval
        
        local fft = self.game.previewModel:getFFT()
        local values = self.values
        local smoothed = self.smoothed_values
        local decay = 0.88
        
        if fft then
            for i = 1, num_bars do
                local bin = bin_mapping[i]
                local gain = gain_curve[i]
                local raw = fft[bin - 1] or 0
                local scaled = raw * gain * 8
                scaled = math.log(scaled * 100 + 1) / math.log(101)
                values[i] = math.max(scaled, values[i] * decay)
                
                smoothed[i] = smoothed[i] * (1 - smoothing_factor) + values[i] * smoothing_factor
            end
        else
            for i = 1, num_bars do
                values[i] = values[i] * decay
                smoothed[i] = smoothed[i] * (1 - smoothing_factor) + values[i] * smoothing_factor
            end
        end
    end
end

function Spectrum:draw()
    local w = self:getCalculatedWidth()
    local h = self:getCalculatedHeight()
    
    if w <= 0 or h <= 0 then
        return
    end
    
    local values = self.smoothed_values
    local c = Colors.accent
    
    local total_bars = num_bars * 2
    local bar_width = w / total_bars
    local line_width = bar_width * 0.8
    local max_bar_height = h * 0.85
    
    love.graphics.setLineWidth(line_width)
    
    for i = 1, num_bars do
        local bar_height = values[i] * max_bar_height
        bar_height = math.sqrt(bar_height / max_bar_height) * max_bar_height
        
        local alpha = math.min(1, bar_height / h + 0.2)
        love.graphics.setColor(c[1], c[2], c[3], c[4] * alpha)
        
        local x = (i - 0.5) * bar_width
        love.graphics.line(x, h, x, h - bar_height)
    end
    
    for i = 1, num_bars do
        local bar_height = values[num_bars - i + 1] * max_bar_height
        bar_height = math.sqrt(bar_height / max_bar_height) * max_bar_height
        
        local alpha = math.min(1, bar_height / h + 0.2)
        love.graphics.setColor(c[1], c[2], c[3], c[4] * alpha)
        
        local x = (num_bars + i - 0.5) * bar_width
        love.graphics.line(x, h, x, h - bar_height)
    end
end

return Spectrum
