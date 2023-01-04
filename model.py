import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import torch
import torch.nn as nn
from torch.autograd import Variable
from sklearn.preprocessing import MinMaxScaler


class LSTM(nn.Module):

    def __init__(self, num_classes, input_size, hidden_size, num_layers):
        super(LSTM, self).__init__()
        
        self.num_classes = num_classes
        self.num_layers = num_layers
        self.input_size = input_size
        self.hidden_size = hidden_size
        self.seq_length = seq_length
        
        self.lstm = nn.LSTM(input_size=input_size, hidden_size=hidden_size,
                            num_layers=num_layers, batch_first=True)
        
        self.fc = nn.Linear(hidden_size, num_classes)

    def forward(self, x):
        h_0 = Variable(torch.zeros(
            self.num_layers, x.size(0), self.hidden_size))
        
        c_0 = Variable(torch.zeros(
            self.num_layers, x.size(0), self.hidden_size))
        
        # Propagate input through LSTM
        ula, (h_out, _) = self.lstm(x, (h_0, c_0))
        
        h_out = h_out.view(-1, self.hidden_size)
        
        out = self.fc(h_out)
        
        return out
      

def test_model(dataset):
  
  model = torch.load("a0001spphire")
  model.eval()
  
  #updated_df = dataset
  
  dataset = pd.DataFrame({'WindSpeed':dataset})
  
  if dataset.isnull().sum()[0] != 0:
    
    dataset['WindSpeed']=dataset['WindSpeed'].fillna(dataset['WindSpeed'].mean())
    dataset.info()
  
  sc = MinMaxScaler()
  test_data = sc.fit_transform(dataset)
  
  testX = Variable(torch.Tensor([np.array(test_data[0:len(test_data)])]))
  
  test_predict = model(testX)
  
  data_predict = test_predict.data.numpy()
  
  sample_predict = sc.inverse_transform(data_predict)
  
  return sample_predict
  
  
#Windspeed to Power conversion
def windToPower(w):
    #w = w[0]
    pRated = 1500
    wRated = 12
    wCutin = 3
    wCutout = 22
    halfSplitter = wRated/1.25
    k = 1.5
    j = -1500
    p = 0
    if (w < wCutin):
        p = 0
    if (w >= wCutin and w < halfSplitter):
        p = pRated * (pow(w,k) - pow(wCutin,k))/(pow(wRated,k) - pow(wCutin,k))
    if (w >= halfSplitter and w < wRated):
        p = pRated * (j*math.exp(-w*0.87))+1550
    if (w >= wRated and w < wCutout):
        p = pRated
    if (w >= wCutout):
        p = 0
    return(p*33/1000)
  
  
  
def apply_wind_energy_formula(wind_speed):
  
  wind_energy_all = list()
  
  for i in windspeed:
    
     wind_energy = windToPower(w)
     
     wind_energy_all.append(wind_energy)
     
     
  return wind_energy_all

