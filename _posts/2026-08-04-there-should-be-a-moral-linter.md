---
layout: post
title: There should be a moral linter
date: '2026-08-04'
kind: notes
tags:
- software
- ethics
- ideas
description: What if there were a linter for life — something that scored a post across
  moral dimensions and said, maybe walk that back, buddy?
slug: there-should-be-a-moral-linter
---

I was thinking about writing a post about moral philosophy after reading [How to be Perfect](https://www.amazon.com/How-Be-Perfect-Correct-Question/dp/1982159316)  by Michael Schur. I thought a funny context would be whether it is worth it confronting your racist grandfather at Thanksgiving. Then I thought, that might really offend people. Like too many people. Offending some people is fine, but maybe that is over the line?

And then I thought… I wish there was a linter for life. Like a moral linter that could go… *maybe you should walk that back buddy.*

The world would be a better place, but how would a moral linter even work?
## What is a Linter?

Lets start with what a linter actually does. Software engineers use many linters everyday and usually love them. I don't think I know a single programmer that dislikes linters. That is because they are little computer programs that run in the background as you write code that prevent you from doing dumb things. One might look for style errors to make code written more consistently for a team while another might make sure you are not using old functions that are going to soon be removed from a library or language. How helpful! 

Man, I wish I could have one of those for everything, but it would certainly be especially helpful when it comes to philosophical questions like *should you confront your racist grandfather at Thanksgiving?*

<div class="callout callout-note">
  <div class="callout-title"><span class="ic">i</span>I do not have a racist grandfather, but if I did, I would wonder what to do.</div>
</div>


## How it could work

It would have to score the thought or concept somehow. If it scored it using a single dimension, I think it would actually end up using a different philosophical framework than if multiple dimensions were used. 
### One Dimension

If we used one dimension, it would be a *utilitarian* linter. Why?

Utilitarianism is what I thought I used to endorse before I got married and had kids. It always tries to maximize the good and minimize the bad. I mean, how can that be wrong? If this sounds familiar, it is because most people have heard about *The Trolly Problem* where a train is careening towards a number of people - 5 or some number greater than one. **But** you can save them! You can pull a lever to make the train switch tracks. The catch is *that would kill one person*.

Yikes. If only we had a moral linter that could help us think about this problem! That linter would notice that whatever you are about to do or say does not actually minimize the suffering of the most people or maximize the good. So in the Trolly Problem, it would say, *whoa! you are standing by a switch that could save some lives! You should pull it!*

So in the case of Thanksgiving it might say, *dude, your grandfather doesn't even leave the house or know how to get on the internet. His crazy opinions have a low chance of hurting others and societal progress does not depend on you changing his mind while everyone else sobs over their mashed potatoes*.

That seems rational, but one dimension is not enough. For instance, what if everyone hated Thanksgiving anyway? Could you verbally accost yout grandfather then? Wait. What if everyone passionately hated him. Could you just murder him? Would that be morally ok? No! Of course not. 

So a single dimensional linter is a broken linter.
<div class="callout callout-note">
  <div class="callout-title"><span class="ic">i</span>Side note about why having kids made me no longer a utilitarian</div>
  <p>If my kid was on the tracks, I would pull the switch to kill the other people. Sorry people!</p>
</div>

### Multiple Dimensions

So we can't use a linter that only optimizes for one parameter. This intuitively makes sense. I mean, if you measure health only by weight, then smoking starts to look pretty healthy!

If we had a linter that could check against a number of rules, we would likely end up with a linter that follows Deontology, which was invented by Emmanuel Kant. Deontology pretty much says that you should create maxims (rules) and those maxims should always be followed - always. For instance, one maxim might be *always tell the truth*. 

In How to be Perfect, Schur uses a great example about a killer knocking on your door asking for your bother. Amazingly, in Deontology land, *lying to the killer would be immoral*. You would have to either tell the truth or say something else that is true, but that might get the killer to leave like *sometimes he runs at the park at this time of day*. 

This is the most code smelly philosophical workaround ever. Linters are made to identify weird ambiguities like this and we just created a giant one with our deontological linter. Kant even gaslights the maxim creator with the perspective that if the maxims like *never lie* and *don't let murderers kill your brother* disagree, then it means that you didn't write them correctly. 

So you would show up at dinner with two rules in your deolntological linter:

- Don't tolerate people saying racist things
- Don't ruin Thanksgiving for your family

Those rules conflict. And it would be *your fault* that you don't know what to do. So deontology is out.
### Bringing sanity to out moral linter

Thank goodness for T.M. Scanlon and his idea of Contractualism. The idea behind contractualism is that *something is wrong if it violates a rule that no one could reasonably reject*. In our case, no reasonable person would think that ruining Thanksgiving for your entire family is ok. No reasonable person would also think it is ok for a racist to spout racist bullshit. Both of things are true on their own and not in rational conflict. Take that, Kant.

Even better, we don't need crazy generalized maxims to follow! We can just look at this situation and decide if a reasonable person would reject it. However, this breaks the entire premise of a moral linter. Linters do what is called *static code analysis*, which is looking at your code without running it. So it doesn't run the code to see what happens. It just looks at pieces of code in isolation and checks if it violates any rules it is set to check against. Ugh... very... Kantian. 

So Scanlon is kind of the rational reason that tells us why **a moral linter just cannot exist**. You cannot build the perfect set of maxims. There will always be some conflict that comes up which is not allowed in Deontology. 

What we need is a runtime evaluation which thankfully, humans are usually capable of. You can imagine what it would be like attacking your grandfather for being a bigot and everyone crying in their mashed potatoes and you can imagine the world not being any better after that - so you don't do it. 

So maybe we don't need a moral linter, but we should probably run the simulation in our heads a few times before we ruin Thanksgiving. 