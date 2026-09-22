---
layout: post
title: Getting My Personal Email Under Control with Hey
date: '2026-09-22'
kind: notes
tags:
- email
- product
- privacy
- productivity
description: How I moved away from Gmail and found peace with Hey email by treating
  email as a workflow problem, not a data problem.
slug: getting-my-personal-email-under-control-with-hey
---

In general, I am constantly overwhelmed with the deluge of communications that stream into my life every single day. I spend a lot of time trying to find ways to reduce that total number so I can spend time doing deep work. From work email and Slack, to personal email and text messages, to social media, it is a stream of constant interruption. It doesn't just prevent me from getting things done — it makes me feel like I am not in charge of my own thoughts. I move from thing to thing that demands my attention and hate it. Finishing replies to 100 Slack messages and seeing double-digit badges on both work and personal email just killed me.

The obvious change I made in my life to fix this was to drop social media. I fire up the web version of Reddit when I just need a minute, but that has obviously been the best thing I have ever done.

This post is about getting my personal email under control, which has felt amazing. For now, let's forget work communication tools since that is a whole separate subject. 
### Gmail

Like most people on this planet, I use Gmail because it is a great application and completely free. Then it just started to feel... *dirty*. Maybe that just means I am finally *woke*, but it became more and more obvious that **I was unintentionally trading my privacy for an email service.** That isn't how commerce works. That is how bad guys in Disney movies work. *It will only cost you **your soul!*** Normal commerce is a justifiable amount of dollars for a service. 

### Solving the Privacy Problem

Luckily, in 2026 there are other options! [Tuta](https://tuta.com/), [Proton](https://proton.me/mail), and [Fastmail](https://www.fastmail.com/) are all great options. I trialed Proton Mail and it was good. It wasn't quite as good as Gmail — it was a bit more clunky, search was worse, and it didn't do a good job swallowing push notifications for emails that I had already read... BUT *I was free!* I was now making an intentional trade-off — a small amount of dollars for a service that didn't use my email to train models and sell me things. **That felt good.**

But *I love software*. I love using great software that people poured their heart into making work a specific way to solve a specific problem. Proton was private, but it just didn't feel great. 

I was also still completely overwhelmed. Proton is a great service, but *I still hated email*. I hated that badge on the app on my phone and I hated rapidly archiving emails from Amazon and everything else between meetings just to triage away the noise. 

So I dropped it. I thought... maybe I don't need some hyper private email. Maybe I just need one that is great and won't sell my data. 

### A Better Email

As a Rails developer, I am keenly aware of 37Signals and remember reading about their [battles](https://www.hey.com/apple/) with Apple about getting their email application in the app store.  So I decided to check out [Hey](https://www.hey.com/) by 37Signals. 

First, their business model is normal commerce - trading a small amount of dollars for a service. No selling data or using my data to train their AI. So the privacy box was checked.

#### The problem with email as it exists today

Now the hard part. I want to like using email again. I want it to stop stressing me out. The main problem with email today is that every email is treated equally. An email from Amazon about a delivery badges my app and demands interaction the same way as an important email from my wife. Remember when GDPR was invented and every service you forgot you signed up for sent you an email? I hated it. Everyone hated it!

Now you might say... just create filters! Sorry, Gmail superuser, that takes too long. I have plenty of filters that were created in a fit of rage and I would rather just archive it while I am walking to the car than make a note to create a filter when I get home. 

#### How Hey is Different

First, every email is blocked by default. That might sound insane, but I have come to realize that it is a genius move. It has something called **The Screener**. When anyone emails you for the first time, it will end up there. You see a little banner in the app saying something is in the screener and you can choose to either block it so it never notifies you ever again or let it in. Awesome. All those lists you tried to unsubscribe from that never worked? GONE with one click. Plus, I kind of love being the final arbiter. I am in charge! I feel like I am doing my future self a favor and really like the process.  

<div class="callout callout-spam">
  <div class="callout-title"><span class="ic">i</span>Don't worry. Hey also has a spam filter that is quite good. You don't have to manually filter through Viagra emails. Those never get to you just like Gmail or any other service.</div>
</div>


Here is where it gets more interesting. Hey is really opinionated. It doesn't just have one inbox. It has three. So when you decide you want to let an email in, you pick one of three destinations.

#### The Imbox
I kind of hate the name, but your primary inbox is called the Imbox — the idea being that emails there are important. Just go with it. 

So if my mom emails me, that goes to my Imbox. 

#### Papertrail
These are transactional emails like receipts, delivery notifications, shipment notifications, etc. In 2026, this is most email. You need to be able to get to it when you want, but you generally don't need to interact with these.

#### The Feed
This is where newsletters go. So products that I love or health newsletters that I want go here. I noticed two interesting things with The Feed.

1. If I have a minute, I am less likely to head to Reddit. I instead will just scroll The Feed.
2. It makes me want to actually sign up for more newsletters. I am on very few because of the way my email used to work and now I kind of want more!

So when an email comes in, you press the thumbs up and pick one of the three. Then that sender will forever just arrive there. My email has never been this calm. My inbox is quiet and I open The Feed or Papertrail whenever I feel like it. I promise that the peace it gives me is worth way more than $5 a month. 
### A weird thing only a fraction of people will care about

Hey is not based on IMAP — the protocol that enables you to use third-party email clients like Apple Mail. At first, I hated that. Then I realized that supporting IMAP would break the workflow that makes Hey... Hey. I actually like the apps a lot. They're a bit cartoon-esque, but they deliver enough peace every day that I don't miss traditional email clients.

However, if you just **need** the app to look different, it has a CLI and a terminal interface. As an engineer, I love that — I could set up a whole different app that works in the Hey way and looks however I want.

Beyond the core workflow, there are tons of other features you'd expect from a modern email service: reply later, snooze (which Hey calls "bubble up"), and more. But the real magic is in the structure. Give it a go. It probably isn't for everyone, but it has done wonders for me.


### Epilogue
#### Two UX gotchas worth knowing

There's a problematic workflow I fell prey to: If you click the thumbs up button in The Screener and then move an email from the Imbox to The Feed or Papertrail, that sender will still be delivered to your Imbox from then on. You *have* to click the destination from The Screener itself. I made that mistake for a week and had to reclassify a bunch of emails. The app makes this mistake way too easy to make.

The second issue: If you want to reclassify a sender later, it's not intuitive. You go to Contacts, choose the sender, choose the new destination, and then get dropped back at the top of Contacts (which is paginated). So as you reclassify each one, you're dropped back at the top and have to find where you were with multiple page loads slowing you down.

**tl;dr:** Classify from The Screener the first time, because doing it in bulk later is a pain. 



