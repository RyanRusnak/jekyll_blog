---
layout: post
title: The Sound of Root Two
date: '2026-08-02'
kind: essay
tags:
- music
- math
description: The math behind why some notes sound good together and others don't —
  clean integer ratios versus the irrational number our ears hate most.
slug: the-sound-of-root-two
math: true
---

I have no idea if we are living in a simulation and I have exactly zero interest in watching a video of Elon Musk pontificating about it. 

However… I do love music. And if you squint hard enough, the math around *what makes music sound good* and *what makes music sound bad* is almost convincing. 

### The Nice Sounds

Picture an **A** note around the middle of a piano. When someone hits it, a string vibrates at 440hz. That feels oddly round. The next **A** note above it is exactly double — a 2:1 ratio making it 880hz. Nice and clean... 

$$880 / 440 = 2:1 $$

And this doubling goes all the way up the piano! 

$$110 \to 220 \to 440 \to 880 $$
 
A geometric series. So nice.

What about a **A** major *chord*? That is an **A** (440Hz), **C#**** 550Hz) and an **E** (660Hz) — Nice big fat integers. As a programmer, that is crazy to me. It just seems too… *clean*. 

$$ 440:550:660 = 4:5:6 $$
### The Bad sounds

What about notes that *don't* sound good together? In general, the chromatic scale is moving up the piano one key at a time so the note right next to **A** is **A#** and pressing both of those keys at once doesn’t sound very good.

Why?

Well, that is what we are figuring out! What we know is this:

The ratios are… *gross*. **A** is 440Hz and the next note up on the chromatic scale is **A#** at 458.33Hz giving it a 25:24 ratio. 

$$458:440 \approx 25:24$$

…woof

### The Worst Sounds

So if that sounds bad, what is the *worst* sounding ratio? Maybe that can help us see how our brain works. Luckily, music is old and people love to complain. There is an old story of something called the [Tritone](https://en.wikipedia.org/wiki/Tritone) or the **Devil’s Chord** which has a great history on its own, but it is usually referenced as the worst sounding noise you can make by combining western musical notes.

It is defined as notes that span 6 semitones. There is music detail in here that we will ignore that has to do with it being two possible notes (**D#** and **Eb** from **A**) depending on sharps and flats which we will ignore and I will just tell you that from **A** the note that makes a tritone is **D#** and that **D#** is 618.75Hz.

 $$440:618.75 \text{ or } 45:32$$ …gross.

Divide 618.75 by 440 and you get 1.40625.

Compare this with the beautiful round integer octaves and chords we started with and you start to see that the grosser the ratio the more our brains don’t like it.

#### The Numbers Behind the Worst Sounds

Instead, of just saying ***D#** is the half way point on the piano between two **A** notes* we will say that *6 is half of the octave* (since there are 12 notes in an octave) and we want that frequency exactly to be exactly 6 semitones away from our starting note. 

Remember that the octaves are a geometric series so you can’t take the half way point between 440 and 880 to find the middle. 

So the half way point between **A** (440Hz) and **A** (880Hz) is:
$$ 440 \times \sqrt{2} \approx 622.25 $$
That is the true halfway point between the **A** notes which is almost the same frequency as **D#**. 

So by definition, if we take the tritone frequency value of A and divide it by the frequency of **A**, you get:
$$ 622.25 \div 440 =1.414$$
Or… the square root of 2.

This tells us that the ratio that our brains **hate the most** is one of the most famous irrational numbers in geometry. 

So next time someone asks “what is the length of the hypotenuse of a triangle with a height and base of 1”, you can just say it is the Devil’s chord and you would be right. 

Our ears love big round integers and hate irrational numbers! If that doesn’t make this whole life thing feel like a video game, then I don’t know what does! 
### Continued Reading for the Naysayers

*But Ryan, music **IS** a geometric series like any other geometric series so root two isn't special! Look at this!

$$ 1 \to  2 \to 4 \to 8 \to 16 \to 32 $$

| Octave    | Midpoint |
| --------- | -------- |
| $1 \to 2$ | 1.414    |
| $2 \to 3$ | 2.828    |
| $3 \to 4$ | 5.657    |

*Ryan!! There is nothing special about root 2 here because that IS how you find the midpoint in geometric series.*

You are totally right. 

But... You hate the sound. You could like it. But you don't.

You **could** but you **don't**!

Why do irrational frequencies have to sound **so bad** to us?

Because the programmers of the universe were lazy - just like us. 