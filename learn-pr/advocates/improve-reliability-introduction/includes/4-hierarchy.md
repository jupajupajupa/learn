The map for the _Improve your Reliability_ learning path is based on a
model from the site reliability engineering world called the Dickerson
Hierarchy of Reliability. Mikey Dickerson was an SRE who became the
founding administrator of the United States Digital Services. He created
this hierarchy while facing one the largest reliability crises he had ever
met.

:::image type="content" source="../media/dickerson-hierarchy.png" alt-text="a diagram of a pyramid showing the seven levels of the hierarchy of reliability.":::

The model is patterned after Abraham Maslow's hierarchy of needs addressing
human motivation. As with Maslow's hierarchy, to progress up the hierarchy
you need to make sure that each of the lower levels has been addressed
first. The levels on which we'll focus in this learning path, from bottom
to top, are:

## Monitoring

This level is the important foundation on which the other levels rest. It's
the source of information that allows you to have concrete conversations
about reliability in your organization around objective data. When you make
changes, this practice is you will know the effect. In even starker terms,
this practice is how you will know whether things are getting better or
not. Until you are solid on our monitoring, you can't get the rest of the
work done.

## Incident response

Every production environment will have an outage of some sort. There's no
disputing this fact. The questions then become "what do you do when an
incident occurs? What happens when systems are down and customers are
impacted?" You need a standard process that is effective at triaging the
problem, getting the right resources engaged, and then mitigating the
issue. At the same time, you also want to make sure you are communicating
with stakeholders about the problem.

## Post-incident review (learning from failure)

This is the process that allows us to level up our operations practices by
collectively investigating, reviewing, and discussing the experience of
each significant incident. This allows us to learn from failure and is
crucial to reliability work.

## Testing/release (deployment)

The next level up is a focus on our testing, release, and deployment
processes. You can think of this level as "how good are you at creating the
systems and processes that can catch problems before they cause incidents?"

## Capacity planning/scaling

Success, and the growth that comes with it can be just as much a threat to
reliability as any problem with a system. A customer can't tell the
difference between a system that is down because there is a bug in the code
and one that is down because too many people are trying to access it at the
same time and it is unable to handle the load. This level of the hierarchy
directs us to pay attention to capacity planning and scaling as ways of
addressing that threat.

## Dev process and user experience

There are two additional levels in the hierarchy that are not addressed in
the _Improve your Reliability_ learning path: the development process and
the work that goes into making a good user experience (UX). We won't be
discussing these two subjects in the _Improve your Reliability_ learning
path, but other good Learn modules on these topics are available.

We have created a separate Learn module for each level in this hierarchy
described above. We hope you will join us for all five modules in this
learning path.
