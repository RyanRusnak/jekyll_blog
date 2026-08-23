---
layout: post
title: Bugs and Asshole Programmers
date: '2026-08-22'
kind: essay
tags:
- ai
- software
- opinion
description: Vibe coding and coding with AI are not the same thing. The best part
  is not the speed — it is never having to route around the one engineer nobody wants
  to talk to.
slug: bugs-and-asshole-programmers
---

Coding with AI vs. *Vibe Coding*. Maybe they are the same thing, but I don't think so. I think vibe coding is just typing into Claude and not caring how it gets made. Coding with AI is typing into Claude, reviewing PRs, tuning markdown to get Claude to operate more like a teammate, and actually engineering the solution in a sustainable way.

### The best parts about coding with AI

##### Bugs

I have spent days of my life stuck on different types of bugs. Who knows how long in total, but certainly time that was not enjoyable. Of course, the moment of victory was sweet, but it was almost always something I did that caused it. Solving a bug that my fallible human brain introduced is like pulling a knife out of my leg that I plunged in. There isn't a whole ton of joy in that. Luckily, I don't do that anymore. AI is **so good** that it just doesn't happen.

##### More Engineering and Fewer Assholes

Almost every engineer has been at a company with too few product people or too few *good* product people. Scoping and designing the solution still has to be done so the engineer ends up doing it. That isn't always a bad thing, but it certainly can be! The reason why is because **the engineer knows how huge of a pain in the ass things are**. The PM and designer usually don't and that makes them the best suited to give the user the best solution. If I realize the best solution for the user requires me to dig into an untested part of the app that only some asshole coworker who should have been fired long ago knows how it works, **I am going to suggest something else**. Sorry user. I am human too and that guy sucks.

<div class="callout callout-info">
  <div class="callout-title"><span class="ic">i</span>Note:</div>
  <p>This references a coworker from two decades ago and not at Airspace! They shall remain anonymous and I hope they have changed their asshole ways.</p>
</div>


With AI, I don't need that guy! I can just point Claude at that part of the application and it will do whatever it needs to get done without ever talking to that guy. Perhaps the biggest victims of AI are the asshole programmers and we shouldn't feel bad for them. They had their chance.

##### The Engineering

Coding is solved. Which is great! I was never the fastest at typing anyway. Now I get to spend way more time thinking about the problem and not how I am going to code the solution. If those things seem like the same thing, that is normal. However, they are different.

*Solving the problem* is *the user is going to click a button and when it works, we will show them a message that says it works.*

*Coding the solution* is *I am going to first register a URL that the front end can use to communicate with the back end that takes these specific parameters. I will sanitize other parameters to guard against injections. Then I will query the DB ensuring no N+1 queries. Then I will respond with the proper error codes. Then I will write the front-end response to the error codes to show the user the status of the system.*

Just writing that out felt archaic.

##### The best programmers use AI

I work with some of the best programmers in the world and the one thing they all have in common is that they haven't written any code in months. They also have shipped more code in those months than ever before. It makes me laugh that online, there is so much debate about whether people should use AI for coding. In the real world, the best people already made their decision.
