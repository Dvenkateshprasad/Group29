# Gender Recognition using Voice
This repository is about building a deep learning model using TensorFlow 2 to recognize gender of a given speaker's audio.

## Requirements
- TensorFlow 2.x.x
- Scikit-learn
- Numpy
- Pandas
- PyAudio
- Librosa

Installing the required libraries:

    pip3 install -r requirements.txt

## Dataset used

[Mozilla's Common Voice](https://www.kaggle.com/mozillaorg/common-voice) large dataset is used here, and some preprocessing has been performed:
- Filtered only the samples that are labeled in `gender` field.
- Balanced the dataset so that number of female samples are equal to male.
- Used [Mel Spectrogram](https://librosa.github.io/librosa/generated/librosa.feature.melspectrogram.html) feature extraction technique to get a vector of a fixed length from each voice sample, the [data](data/) folder contain only the features extracted from the files

## Training
    python train.py

## Testing

- For instance, to get gender of the file `test-samples/27-124992-0002.wav`, you can:

      python test.py --file "test-samples/27-124992-0002.wav"

    **Output:**

      Result: male
      Probabilities:     Male: 96.36%    Female: 3.64%
  
  There are some audio samples in [test-samples](test-samples) folder for you to test with, it is grabbed from [LibriSpeech dataset](http://www.openslr.org/12).
- To make inference on your voice instead, you need to:
      
      python test.py

    Wait until you see `"Please speak"` prompt and start talking, it will stop recording as long as you stop talking.

    