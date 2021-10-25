#%%
from neuralprophet import NeuralProphet

#%%
m = Prophet()
metrics = m.fit(df, freq="D")
forecast = m.predict(df)

#%%
fig_forecast = m.plot(forecast)
fig_components = m.plot_components(forecast)
fig_model = m.plot_parameters()

m = NeuralProphet().fit(df, freq="D")
df_future = m.make_future_dataframe(df, periods=30)
forecast = m.predict(df_future)
fig_forecast = m.plot(forecast)