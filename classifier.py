from rcaudio import CoreRecorder
from tflite_runtime.interpreter import Interpreter
import librosa
import numpy as np
import wave
import pyaudio
import requests
import json
import datetime

sample_rate = 44100
global CR

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
    info = p.get_host_api_info_by_index(0)
    numdevices = info.get('deviceCount')
    for i in range(0, numdevices):
        if (p.get_device_info_by_host_api_device_index(0, i).get('maxInputChannels')) > 0:
             print("Input Device id ", i, " - ", p.get_device_info_by_host_api_device_index(0, i).get('name'))
    print('Recording')
    mic1 = p.get_device_info_by_host_api_device_index(0, 1).get('name')

    stream = p.open(format=sample_format,
                    channels=channels,
                    rate=fs,
                    frames_per_buffer=chunk,
                    input=True,
                    input_device_index=1)

    frames = []  # Initialize array to store frames

    # Store data in chunks for 3 seconds
    for _ in range(0, int(fs / chunk * seconds)):
        data = stream.read(chunk, exception_on_overflow = False)
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
    #wf = wave.open(filename, 'wb')
    #wf.setnchannels(channels)
    #wf.setsampwidth(p.get_sample_size(sample_format))
    #wf.setframerate(fs)
    #wf.writeframes(b''.join(frames))
    #wf.close()
    return (frames, mic1)

counter = 0

def write_firebase(classification, pi_identifier, mic):
    data = {"Class": classification,
            "Time": str(datetime.datetime.now()),
            "Microphone": mic}

    requests.put(f"https://project-gunshot-default-rtdb.firebaseio.com/RaspberryPi{pi_identifier}/sound{counter}.json",
                 json.dumps(data))

while True:
    frames, micID = pyaudio_record()
    samples = np.array(frames, dtype="float32")
    # CR.save_wave_file("recorded_sample.wav", samples)
    extracted = extractFeaturesArr(samples, sample_rate)
    result = predict(extracted)
    write_firebase(classification=result, pi_identifier=2, mic=micID) 
    counter += 1 
    
