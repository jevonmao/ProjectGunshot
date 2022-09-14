from rcaudio import CoreRecorder
from tflite_runtime.interpreter import Interpreter
import librosa
import numpy as np
import wave
import pyaudio


sample_rate = 44100
global CR

def sampleSound(seconds):
    threshold = 1 # required number of gunshots, in most recent 5 predictions,
                    # to make final decision
    global CR
    CR = CoreRecorder(
            time = seconds, # How much time to record
            sr = sample_rate # sample rate
            )
    CR.start()
    data = [0]  * sample_rate

    while True:
        if not CR.buffer.empty():
            x = CR.buffer.get()
            data.append(x)
            if len(data) // sample_rate == seconds + 1:
                break

    return data

def extractFeatures(file_name):

    try:
        audio, sample_rate = librosa.load(file_name, res_type='kaiser_fast')
        mfccs = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=40)
        mfccsscaled = np.mean(mfccs.T,axis=0)

    except Exception as e:
        print("Error encountered while parsing file: ", file)
        return None

    return mfccsscaled

def extractFeaturesArr(audio_arr, sample_rate):

    mfccs = librosa.feature.mfcc(y=audio_arr, sr=sample_rate, n_mfcc=40)
    mfccsscaled = np.mean(mfccs.T,axis=0)

    return mfccsscaled

def predict(input):
        num_rows = 4
        num_columns = 10
        num_channels = 1
        num_labels = 2

        input = input.reshape(1, num_rows, num_columns, num_channels)
        interpreter = Interpreter("model.tflite")
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        interpreter.set_tensor(input_details[0]['index'], input)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details[0]['index'])

        classes = {'0': 'no_gun_shot', '1': 'gun_shot'}
        output = np.argmax(output_data[0])
        print(output)
        pred_index = str(output)
        pred_class = classes[pred_index]
        return pred_class

def extract_features(file_name):
    try:
        audio, sample_rate = librosa.load(file_name, res_type='kaiser_fast') 
        mfccs = librosa.feature.mfcc(y=audio, sr=sample_rate, n_mfcc=40)
        mfccsscaled = np.mean(mfccs.T,axis=0)
        
    except Exception as e:
        print("Error encountered while parsing file: ", file)
        return None 
     
    return mfccsscaled

def pyaudio_record():
    chunk = 1024  # Record in chunks of 1024 samples
    sample_format = pyaudio.paInt16  # 16 bits per sample
    channels = 1
    fs = 44100  # Record at 44100 samples per second
    seconds = 3
    filename = "output.wav"

    p = pyaudio.PyAudio()  # Create an interface to PortAudio

    print('Recording')

    stream = p.open(format=sample_format,
                    channels=channels,
                    rate=fs,
                    frames_per_buffer=chunk,
                    input=True,
                    input_device_index=1)

    frames = []  # Initialize array to store frames

    # Store data in chunks for 3 seconds
    for _ in range(0, int(fs / chunk * seconds)):
        data = stream.read(chunk)
        np_float = np.fromstring(data, dtype = np.short)
        for i in np_float:
            frames.append(i)

    # Stop and close the stream 
    stream.stop_stream()
    stream.close()
    # Terminate the PortAudio interface
    p.terminate()

    print('Finished recording')

    # Save the recorded data as a WAV file
    wf = wave.open(filename, 'wb')
    wf.setnchannels(channels)
    wf.setsampwidth(p.get_sample_size(sample_format))
    wf.setframerate(fs)
    wf.writeframes(b''.join(frames))
    wf.close()
    return frames

samples = np.array(pyaudio_record(), dtype="float32")
# CR.save_wave_file("recorded_sample.wav", samples)
extracted = extractFeaturesArr(samples, sample_rate)
result = predict(extracted)
print(result)