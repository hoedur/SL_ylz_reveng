
libbl_vii_jni.so:     file format elf32-littlearm


Disassembly of section .plt:

00001334 <__cxa_finalize@plt-0x14>:
    1334:	e52de004 	push	{lr}		@ (str lr, [sp, #-4]!)
    1338:	e59fe004 	ldr	lr, [pc, #4]	@ 1344 <__cxa_finalize@plt-0x4>
    133c:	e08fe00e 	add	lr, pc, lr
    1340:	e5bef008 	ldr	pc, [lr, #8]!
    1344:	00005be4 	andeq	r5, r0, r4, ror #23

00001348 <__cxa_finalize@plt>:
    1348:	e28fc600 	add	ip, pc, #0, 12
    134c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1350:	e5bcfbe4 	ldr	pc, [ip, #3044]!	@ 0xbe4

00001354 <__cxa_atexit@plt>:
    1354:	e28fc600 	add	ip, pc, #0, 12
    1358:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    135c:	e5bcfbdc 	ldr	pc, [ip, #3036]!	@ 0xbdc

00001360 <__register_atfork@plt>:
    1360:	e28fc600 	add	ip, pc, #0, 12
    1364:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1368:	e5bcfbd4 	ldr	pc, [ip, #3028]!	@ 0xbd4

0000136c <__strcpy_chk@plt>:
    136c:	e28fc600 	add	ip, pc, #0, 12
    1370:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1374:	e5bcfbcc 	ldr	pc, [ip, #3020]!	@ 0xbcc

00001378 <create_instance@plt>:
    1378:	e28fc600 	add	ip, pc, #0, 12
    137c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1380:	e5bcfbc4 	ldr	pc, [ip, #3012]!	@ 0xbc4

00001384 <mjpeg_ndk_frame_callback_register@plt>:
    1384:	e28fc600 	add	ip, pc, #0, 12
    1388:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    138c:	e5bcfbbc 	ldr	pc, [ip, #3004]!	@ 0xbbc

00001390 <mjpeg_ndk_ctlmsg_cb_register@plt>:
    1390:	e28fc600 	add	ip, pc, #0, 12
    1394:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1398:	e5bcfbb4 	ldr	pc, [ip, #2996]!	@ 0xbb4

0000139c <mjpeg_ndk_startup@plt>:
    139c:	e28fc600 	add	ip, pc, #0, 12
    13a0:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    13a4:	e5bcfbac 	ldr	pc, [ip, #2988]!	@ 0xbac

000013a8 <thread_ctl@plt>:
    13a8:	e28fc600 	add	ip, pc, #0, 12
    13ac:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    13b0:	e5bcfba4 	ldr	pc, [ip, #2980]!	@ 0xba4

000013b4 <__stack_chk_fail@plt>:
    13b4:	e28fc600 	add	ip, pc, #0, 12
    13b8:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    13bc:	e5bcfb9c 	ldr	pc, [ip, #2972]!	@ 0xb9c

000013c0 <mjpeg_ndk_frame_callback_unregister@plt>:
    13c0:	e28fc600 	add	ip, pc, #0, 12
    13c4:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    13c8:	e5bcfb94 	ldr	pc, [ip, #2964]!	@ 0xb94

000013cc <mjpeg_ndk_stop@plt>:
    13cc:	e28fc600 	add	ip, pc, #0, 12
    13d0:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    13d4:	e5bcfb8c 	ldr	pc, [ip, #2956]!	@ 0xb8c

000013d8 <destroy_instance@plt>:
    13d8:	e28fc600 	add	ip, pc, #0, 12
    13dc:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    13e0:	e5bcfb84 	ldr	pc, [ip, #2948]!	@ 0xb84

000013e4 <mjpeg_ndk_set_active_camera_index@plt>:
    13e4:	e28fc600 	add	ip, pc, #0, 12
    13e8:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    13ec:	e5bcfb7c 	ldr	pc, [ip, #2940]!	@ 0xb7c

000013f0 <mjpeg_ndk_set_QPara@plt>:
    13f0:	e28fc600 	add	ip, pc, #0, 12
    13f4:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    13f8:	e5bcfb74 	ldr	pc, [ip, #2932]!	@ 0xb74

000013fc <calloc@plt>:
    13fc:	e28fc600 	add	ip, pc, #0, 12
    1400:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1404:	e5bcfb6c 	ldr	pc, [ip, #2924]!	@ 0xb6c

00001408 <gettimeofday@plt>:
    1408:	e28fc600 	add	ip, pc, #0, 12
    140c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1410:	e5bcfb64 	ldr	pc, [ip, #2916]!	@ 0xb64

00001414 <getaddrinfo@plt>:
    1414:	e28fc600 	add	ip, pc, #0, 12
    1418:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    141c:	e5bcfb5c 	ldr	pc, [ip, #2908]!	@ 0xb5c

00001420 <socket@plt>:
    1420:	e28fc600 	add	ip, pc, #0, 12
    1424:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1428:	e5bcfb54 	ldr	pc, [ip, #2900]!	@ 0xb54

0000142c <setsockopt@plt>:
    142c:	e28fc600 	add	ip, pc, #0, 12
    1430:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1434:	e5bcfb4c 	ldr	pc, [ip, #2892]!	@ 0xb4c

00001438 <bind@plt>:
    1438:	e28fc600 	add	ip, pc, #0, 12
    143c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1440:	e5bcfb44 	ldr	pc, [ip, #2884]!	@ 0xb44

00001444 <getsockname@plt>:
    1444:	e28fc600 	add	ip, pc, #0, 12
    1448:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    144c:	e5bcfb3c 	ldr	pc, [ip, #2876]!	@ 0xb3c

00001450 <freeaddrinfo@plt>:
    1450:	e28fc600 	add	ip, pc, #0, 12
    1454:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1458:	e5bcfb34 	ldr	pc, [ip, #2868]!	@ 0xb34

0000145c <perror@plt>:
    145c:	e28fc600 	add	ip, pc, #0, 12
    1460:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1464:	e5bcfb2c 	ldr	pc, [ip, #2860]!	@ 0xb2c

00001468 <exit@plt>:
    1468:	e28fc600 	add	ip, pc, #0, 12
    146c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1470:	e5bcfb24 	ldr	pc, [ip, #2852]!	@ 0xb24

00001474 <usleep@plt>:
    1474:	e28fc600 	add	ip, pc, #0, 12
    1478:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    147c:	e5bcfb1c 	ldr	pc, [ip, #2844]!	@ 0xb1c

00001480 <time_interval_ms@plt>:
    1480:	e28fc600 	add	ip, pc, #0, 12
    1484:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1488:	e5bcfb14 	ldr	pc, [ip, #2836]!	@ 0xb14

0000148c <__android_log_print@plt>:
    148c:	e28fc600 	add	ip, pc, #0, 12
    1490:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1494:	e5bcfb0c 	ldr	pc, [ip, #2828]!	@ 0xb0c

00001498 <__aeabi_memclr@plt>:
    1498:	e28fc600 	add	ip, pc, #0, 12
    149c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    14a0:	e5bcfb04 	ldr	pc, [ip, #2820]!	@ 0xb04

000014a4 <sendto@plt>:
    14a4:	e28fc600 	add	ip, pc, #0, 12
    14a8:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    14ac:	e5bcfafc 	ldr	pc, [ip, #2812]!	@ 0xafc

000014b0 <pthread_mutex_lock@plt>:
    14b0:	e28fc600 	add	ip, pc, #0, 12
    14b4:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    14b8:	e5bcfaf4 	ldr	pc, [ip, #2804]!	@ 0xaf4

000014bc <build_send_ack@plt>:
    14bc:	e28fc600 	add	ip, pc, #0, 12
    14c0:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    14c4:	e5bcfaec 	ldr	pc, [ip, #2796]!	@ 0xaec

000014c8 <pthread_mutex_unlock@plt>:
    14c8:	e28fc600 	add	ip, pc, #0, 12
    14cc:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    14d0:	e5bcfae4 	ldr	pc, [ip, #2788]!	@ 0xae4

000014d4 <read@plt>:
    14d4:	e28fc600 	add	ip, pc, #0, 12
    14d8:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    14dc:	e5bcfadc 	ldr	pc, [ip, #2780]!	@ 0xadc

000014e0 <handle_mcu_msg_frag@plt>:
    14e0:	e28fc600 	add	ip, pc, #0, 12
    14e4:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    14e8:	e5bcfad4 	ldr	pc, [ip, #2772]!	@ 0xad4

000014ec <handle_mcu_msg_ack@plt>:
    14ec:	e28fc600 	add	ip, pc, #0, 12
    14f0:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    14f4:	e5bcfacc 	ldr	pc, [ip, #2764]!	@ 0xacc

000014f8 <handle_mcu_msg_ctlmsg@plt>:
    14f8:	e28fc600 	add	ip, pc, #0, 12
    14fc:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1500:	e5bcfac4 	ldr	pc, [ip, #2756]!	@ 0xac4

00001504 <handle_mcu_msg_queryinfo_resp@plt>:
    1504:	e28fc600 	add	ip, pc, #0, 12
    1508:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    150c:	e5bcfabc 	ldr	pc, [ip, #2748]!	@ 0xabc

00001510 <close@plt>:
    1510:	e28fc600 	add	ip, pc, #0, 12
    1514:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1518:	e5bcfab4 	ldr	pc, [ip, #2740]!	@ 0xab4

0000151c <free@plt>:
    151c:	e28fc600 	add	ip, pc, #0, 12
    1520:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1524:	e5bcfaac 	ldr	pc, [ip, #2732]!	@ 0xaac

00001528 <__aeabi_memcpy@plt>:
    1528:	e28fc600 	add	ip, pc, #0, 12
    152c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1530:	e5bcfaa4 	ldr	pc, [ip, #2724]!	@ 0xaa4

00001534 <__aeabi_memset@plt>:
    1534:	e28fc600 	add	ip, pc, #0, 12
    1538:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    153c:	e5bcfa9c 	ldr	pc, [ip, #2716]!	@ 0xa9c

00001540 <inet_ntop@plt>:
    1540:	e28fc600 	add	ip, pc, #0, 12
    1544:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1548:	e5bcfa94 	ldr	pc, [ip, #2708]!	@ 0xa94

0000154c <__strncpy_chk2@plt>:
    154c:	e28fc600 	add	ip, pc, #0, 12
    1550:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1554:	e5bcfa8c 	ldr	pc, [ip, #2700]!	@ 0xa8c

00001558 <fprintf@plt>:
    1558:	e28fc600 	add	ip, pc, #0, 12
    155c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1560:	e5bcfa84 	ldr	pc, [ip, #2692]!	@ 0xa84

00001564 <fflush@plt>:
    1564:	e28fc600 	add	ip, pc, #0, 12
    1568:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    156c:	e5bcfa7c 	ldr	pc, [ip, #2684]!	@ 0xa7c

00001570 <abort@plt>:
    1570:	e28fc600 	add	ip, pc, #0, 12
    1574:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1578:	e5bcfa74 	ldr	pc, [ip, #2676]!	@ 0xa74

0000157c <dladdr@plt>:
    157c:	e28fc600 	add	ip, pc, #0, 12
    1580:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1584:	e5bcfa6c 	ldr	pc, [ip, #2668]!	@ 0xa6c

00001588 <snprintf@plt>:
    1588:	e28fc600 	add	ip, pc, #0, 12
    158c:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    1590:	e5bcfa64 	ldr	pc, [ip, #2660]!	@ 0xa64

00001594 <__gnu_Unwind_Find_exidx@plt>:
    1594:	e28fc600 	add	ip, pc, #0, 12
    1598:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    159c:	e5bcfa5c 	ldr	pc, [ip, #2652]!	@ 0xa5c

000015a0 <raise@plt>:
    15a0:	e28fc600 	add	ip, pc, #0, 12
    15a4:	e28cca05 	add	ip, ip, #20480	@ 0x5000
    15a8:	e5bcfa54 	ldr	pc, [ip, #2644]!	@ 0xa54

Disassembly of section .text:

000015b0 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base-0x54>:
    15b0:	e59f0004 	ldr	r0, [pc, #4]	@ 15bc <raise@plt+0x1c>
    15b4:	e08f0000 	add	r0, pc, r0
    15b8:	eaffff62 	b	1348 <__cxa_finalize@plt>
    15bc:	000057b0 			@ <UNDEFINED> instruction: 0x000057b0
    15c0:	e12fff1e 	bx	lr
    15c4:	eafffffd 	b	15c0 <raise@plt+0x20>
    15c8:	e3500000 	cmp	r0, #0
    15cc:	012fff1e 	bxeq	lr
    15d0:	e12fff10 	bx	r0
    15d4:	e1a01000 	mov	r1, r0
    15d8:	e59f000c 	ldr	r0, [pc, #12]	@ 15ec <raise@plt+0x4c>
    15dc:	e59f200c 	ldr	r2, [pc, #12]	@ 15f0 <raise@plt+0x50>
    15e0:	e08f0000 	add	r0, pc, r0
    15e4:	e08f2002 	add	r2, pc, r2
    15e8:	eaffff59 	b	1354 <__cxa_atexit@plt>
    15ec:	ffffffe0 			@ <UNDEFINED> instruction: 0xffffffe0
    15f0:	00005780 	andeq	r5, r0, r0, lsl #15
    15f4:	e59f3004 	ldr	r3, [pc, #4]	@ 1600 <raise@plt+0x60>
    15f8:	e08f3003 	add	r3, pc, r3
    15fc:	eaffff57 	b	1360 <__register_atfork@plt>
    1600:	0000576c 	andeq	r5, r0, ip, ror #14

00001604 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base>:
    1604:	b5f0      	push	{r4, r5, r6, r7, lr}
    1606:	af03      	add	r7, sp, #12
    1608:	e92d 0b00 	stmdb	sp!, {r8, r9, fp}
    160c:	b08a      	sub	sp, #40	@ 0x28
    160e:	4604      	mov	r4, r0
    1610:	4838      	ldr	r0, [pc, #224]	@ (16f4 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0xf0>)
    1612:	4691      	mov	r9, r2
    1614:	460e      	mov	r6, r1
    1616:	4478      	add	r0, pc
    1618:	6805      	ldr	r5, [r0, #0]
    161a:	602c      	str	r4, [r5, #0]
    161c:	4836      	ldr	r0, [pc, #216]	@ (16f8 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0xf4>)
    161e:	4478      	add	r0, pc
    1620:	f8d0 8000 	ldr.w	r8, [r0]
    1624:	f8d8 0000 	ldr.w	r0, [r8]
    1628:	9009      	str	r0, [sp, #36]	@ 0x24
    162a:	6820      	ldr	r0, [r4, #0]
    162c:	f8d0 236c 	ldr.w	r2, [r0, #876]	@ 0x36c
    1630:	4832      	ldr	r0, [pc, #200]	@ (16fc <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0xf8>)
    1632:	4478      	add	r0, pc
    1634:	6801      	ldr	r1, [r0, #0]
    1636:	4620      	mov	r0, r4
    1638:	4790      	blx	r2
    163a:	6828      	ldr	r0, [r5, #0]
    163c:	6801      	ldr	r1, [r0, #0]
    163e:	6d4a      	ldr	r2, [r1, #84]	@ 0x54
    1640:	4631      	mov	r1, r6
    1642:	4790      	blx	r2
    1644:	492e      	ldr	r1, [pc, #184]	@ (1700 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0xfc>)
    1646:	2200      	movs	r2, #0
    1648:	4479      	add	r1, pc
    164a:	6809      	ldr	r1, [r1, #0]
    164c:	6008      	str	r0, [r1, #0]
    164e:	4649      	mov	r1, r9
    1650:	6820      	ldr	r0, [r4, #0]
    1652:	f8d0 32a4 	ldr.w	r3, [r0, #676]	@ 0x2a4
    1656:	4620      	mov	r0, r4
    1658:	4798      	blx	r3
    165a:	ad01      	add	r5, sp, #4
    165c:	4601      	mov	r1, r0
    165e:	2220      	movs	r2, #32
    1660:	4628      	mov	r0, r5
    1662:	f7ff ee84 	blx	136c <__strcpy_chk@plt>
    1666:	4a27      	ldr	r2, [pc, #156]	@ (1704 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x100>)
    1668:	2000      	movs	r0, #0
    166a:	4629      	mov	r1, r5
    166c:	447a      	add	r2, pc
    166e:	f7ff ee84 	blx	1378 <create_instance@plt>
    1672:	4925      	ldr	r1, [pc, #148]	@ (1708 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x104>)
    1674:	4a1b      	ldr	r2, [pc, #108]	@ (16e4 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0xe0>)
    1676:	4479      	add	r1, pc
    1678:	680d      	ldr	r5, [r1, #0]
    167a:	6028      	str	r0, [r5, #0]
    167c:	4923      	ldr	r1, [pc, #140]	@ (170c <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x108>)
    167e:	4479      	add	r1, pc
    1680:	f7ff ee80 	blx	1384 <mjpeg_ndk_frame_callback_register@plt>
    1684:	6828      	ldr	r0, [r5, #0]
    1686:	4922      	ldr	r1, [pc, #136]	@ (1710 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x10c>)
    1688:	4479      	add	r1, pc
    168a:	f7ff ee82 	blx	1390 <mjpeg_ndk_ctlmsg_cb_register@plt>
    168e:	6828      	ldr	r0, [r5, #0]
    1690:	f7ff ee84 	blx	139c <mjpeg_ndk_startup@plt>
    1694:	6828      	ldr	r0, [r5, #0]
    1696:	f7ff ee88 	blx	13a8 <thread_ctl@plt>
    169a:	6828      	ldr	r0, [r5, #0]
    169c:	4912      	ldr	r1, [pc, #72]	@ (16e8 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0xe4>)
    169e:	5840      	ldr	r0, [r0, r1]
    16a0:	491c      	ldr	r1, [pc, #112]	@ (1714 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x110>)
    16a2:	4479      	add	r1, pc
    16a4:	680e      	ldr	r6, [r1, #0]
    16a6:	2100      	movs	r1, #0
    16a8:	47b0      	blx	r6
    16aa:	6828      	ldr	r0, [r5, #0]
    16ac:	490f      	ldr	r1, [pc, #60]	@ (16ec <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0xe8>)
    16ae:	5840      	ldr	r0, [r0, r1]
    16b0:	2100      	movs	r1, #0
    16b2:	47b0      	blx	r6
    16b4:	6828      	ldr	r0, [r5, #0]
    16b6:	490e      	ldr	r1, [pc, #56]	@ (16f0 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0xec>)
    16b8:	5840      	ldr	r0, [r0, r1]
    16ba:	2100      	movs	r1, #0
    16bc:	47b0      	blx	r6
    16be:	6820      	ldr	r0, [r4, #0]
    16c0:	f8d0 229c 	ldr.w	r2, [r0, #668]	@ 0x29c
    16c4:	4620      	mov	r0, r4
    16c6:	4914      	ldr	r1, [pc, #80]	@ (1718 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x114>)
    16c8:	4479      	add	r1, pc
    16ca:	4790      	blx	r2
    16cc:	f8d8 1000 	ldr.w	r1, [r8]
    16d0:	9a09      	ldr	r2, [sp, #36]	@ 0x24
    16d2:	1a89      	subs	r1, r1, r2
    16d4:	bf02      	ittt	eq
    16d6:	b00a      	addeq	sp, #40	@ 0x28
    16d8:	e8bd 0b00 	ldmiaeq.w	sp!, {r8, r9, fp}
    16dc:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    16de:	f7ff ee6a 	blx	13b4 <__stack_chk_fail@plt>
    16e2:	bf00      	nop
    16e4:	3210      	adds	r2, #16
    16e6:	7654      	strb	r4, [r2, #25]
    16e8:	03c4      	lsls	r4, r0, #15
    16ea:	0070      	lsls	r0, r6, #1
    16ec:	03c8      	lsls	r0, r1, #15
    16ee:	0070      	lsls	r0, r6, #1
    16f0:	03cc      	lsls	r4, r1, #15
    16f2:	0070      	lsls	r0, r6, #1
    16f4:	58b6      	ldr	r6, [r6, r2]
    16f6:	0000      	movs	r0, r0
    16f8:	58b2      	ldr	r2, [r6, r2]
    16fa:	0000      	movs	r0, r0
    16fc:	58a2      	ldr	r2, [r4, r2]
    16fe:	0000      	movs	r0, r0
    1700:	5890      	ldr	r0, [r2, r2]
    1702:	0000      	movs	r0, r0
    1704:	2fd4      	cmp	r7, #212	@ 0xd4
    1706:	0000      	movs	r0, r0
    1708:	5866      	ldr	r6, [r4, r1]
    170a:	0000      	movs	r0, r0
    170c:	009b      	lsls	r3, r3, #2
    170e:	0000      	movs	r0, r0
    1710:	017d      	lsls	r5, r7, #5
    1712:	0000      	movs	r0, r0
    1714:	583e      	ldr	r6, [r7, r0]
    1716:	0000      	movs	r0, r0
    1718:	2f7d      	cmp	r7, #125	@ 0x7d
    171a:	0000      	movs	r0, r0
    171c:	b5f0      	push	{r4, r5, r6, r7, lr}
    171e:	af03      	add	r7, sp, #12
    1720:	e92d 0f00 	stmdb	sp!, {r8, r9, sl, fp}
    1724:	b089      	sub	sp, #36	@ 0x24
    1726:	4683      	mov	fp, r0
    1728:	4834      	ldr	r0, [pc, #208]	@ (17fc <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x1f8>)
    172a:	6954      	ldr	r4, [r2, #20]
    172c:	468a      	mov	sl, r1
    172e:	4478      	add	r0, pc
    1730:	4616      	mov	r6, r2
    1732:	6800      	ldr	r0, [r0, #0]
    1734:	6801      	ldr	r1, [r0, #0]
    1736:	6820      	ldr	r0, [r4, #0]
    1738:	6fc2      	ldr	r2, [r0, #124]	@ 0x7c
    173a:	4620      	mov	r0, r4
    173c:	4790      	blx	r2
    173e:	2800      	cmp	r0, #0
    1740:	d058      	beq.n	17f4 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x1f0>
    1742:	4681      	mov	r9, r0
    1744:	6820      	ldr	r0, [r4, #0]
    1746:	4649      	mov	r1, r9
    1748:	f8d0 51c4 	ldr.w	r5, [r0, #452]	@ 0x1c4
    174c:	4620      	mov	r0, r4
    174e:	4a2c      	ldr	r2, [pc, #176]	@ (1800 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x1fc>)
    1750:	4b2c      	ldr	r3, [pc, #176]	@ (1804 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x200>)
    1752:	447a      	add	r2, pc
    1754:	447b      	add	r3, pc
    1756:	47a8      	blx	r5
    1758:	9008      	str	r0, [sp, #32]
    175a:	e9d6 1000 	ldrd	r1, r0, [r6]
    175e:	9105      	str	r1, [sp, #20]
    1760:	4651      	mov	r1, sl
    1762:	9007      	str	r0, [sp, #28]
    1764:	f996 0008 	ldrsb.w	r0, [r6, #8]
    1768:	9006      	str	r0, [sp, #24]
    176a:	6820      	ldr	r0, [r4, #0]
    176c:	f8d0 22c0 	ldr.w	r2, [r0, #704]	@ 0x2c0
    1770:	4620      	mov	r0, r4
    1772:	4790      	blx	r2
    1774:	4680      	mov	r8, r0
    1776:	6820      	ldr	r0, [r4, #0]
    1778:	4641      	mov	r1, r8
    177a:	2200      	movs	r2, #0
    177c:	4653      	mov	r3, sl
    177e:	f8d0 5340 	ldr.w	r5, [r0, #832]	@ 0x340
    1782:	4620      	mov	r0, r4
    1784:	f8cd b000 	str.w	fp, [sp]
    1788:	47a8      	blx	r5
    178a:	6820      	ldr	r0, [r4, #0]
    178c:	210b      	movs	r1, #11
    178e:	f8d0 22c0 	ldr.w	r2, [r0, #704]	@ 0x2c0
    1792:	4620      	mov	r0, r4
    1794:	4790      	blx	r2
    1796:	4605      	mov	r5, r0
    1798:	6820      	ldr	r0, [r4, #0]
    179a:	4629      	mov	r1, r5
    179c:	2200      	movs	r2, #0
    179e:	230b      	movs	r3, #11
    17a0:	f8d0 c340 	ldr.w	ip, [r0, #832]	@ 0x340
    17a4:	f106 0009 	add.w	r0, r6, #9
    17a8:	9000      	str	r0, [sp, #0]
    17aa:	4620      	mov	r0, r4
    17ac:	47e0      	blx	ip
    17ae:	6820      	ldr	r0, [r4, #0]
    17b0:	4649      	mov	r1, r9
    17b2:	4643      	mov	r3, r8
    17b4:	f8d0 6204 	ldr.w	r6, [r0, #516]	@ 0x204
    17b8:	9805      	ldr	r0, [sp, #20]
    17ba:	9000      	str	r0, [sp, #0]
    17bc:	9807      	ldr	r0, [sp, #28]
    17be:	9001      	str	r0, [sp, #4]
    17c0:	9806      	ldr	r0, [sp, #24]
    17c2:	e9cd 0502 	strd	r0, r5, [sp, #8]
    17c6:	4620      	mov	r0, r4
    17c8:	9a08      	ldr	r2, [sp, #32]
    17ca:	47b0      	blx	r6
    17cc:	6820      	ldr	r0, [r4, #0]
    17ce:	4629      	mov	r1, r5
    17d0:	6dc2      	ldr	r2, [r0, #92]	@ 0x5c
    17d2:	4620      	mov	r0, r4
    17d4:	4790      	blx	r2
    17d6:	6820      	ldr	r0, [r4, #0]
    17d8:	4641      	mov	r1, r8
    17da:	6dc2      	ldr	r2, [r0, #92]	@ 0x5c
    17dc:	4620      	mov	r0, r4
    17de:	4790      	blx	r2
    17e0:	6820      	ldr	r0, [r4, #0]
    17e2:	4649      	mov	r1, r9
    17e4:	6dc2      	ldr	r2, [r0, #92]	@ 0x5c
    17e6:	4620      	mov	r0, r4
    17e8:	b009      	add	sp, #36	@ 0x24
    17ea:	e8bd 0f00 	ldmia.w	sp!, {r8, r9, sl, fp}
    17ee:	e8bd 40f0 	ldmia.w	sp!, {r4, r5, r6, r7, lr}
    17f2:	4710      	bx	r2
    17f4:	b009      	add	sp, #36	@ 0x24
    17f6:	e8bd 0f00 	ldmia.w	sp!, {r8, r9, sl, fp}
    17fa:	bdf0      	pop	{r4, r5, r6, r7, pc}
    17fc:	57aa      	ldrsb	r2, [r5, r6]
    17fe:	0000      	movs	r0, r0
    1800:	2f29      	cmp	r7, #41	@ 0x29
    1802:	0000      	movs	r0, r0
    1804:	2f3a      	cmp	r7, #58	@ 0x3a
    1806:	0000      	movs	r0, r0
    1808:	b5f0      	push	{r4, r5, r6, r7, lr}
    180a:	af03      	add	r7, sp, #12
    180c:	e92d 0fe0 	stmdb	sp!, {r5, r6, r7, r8, r9, sl, fp}
    1810:	9202      	str	r2, [sp, #8]
    1812:	4681      	mov	r9, r0
    1814:	4820      	ldr	r0, [pc, #128]	@ (1898 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x294>)
    1816:	4688      	mov	r8, r1
    1818:	461c      	mov	r4, r3
    181a:	4478      	add	r0, pc
    181c:	6800      	ldr	r0, [r0, #0]
    181e:	6801      	ldr	r1, [r0, #0]
    1820:	6818      	ldr	r0, [r3, #0]
    1822:	6fc2      	ldr	r2, [r0, #124]	@ 0x7c
    1824:	4618      	mov	r0, r3
    1826:	4790      	blx	r2
    1828:	4683      	mov	fp, r0
    182a:	6820      	ldr	r0, [r4, #0]
    182c:	4659      	mov	r1, fp
    182e:	f8d0 51c4 	ldr.w	r5, [r0, #452]	@ 0x1c4
    1832:	4620      	mov	r0, r4
    1834:	4a19      	ldr	r2, [pc, #100]	@ (189c <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x298>)
    1836:	4b1a      	ldr	r3, [pc, #104]	@ (18a0 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onStart@@Base+0x29c>)
    1838:	447a      	add	r2, pc
    183a:	447b      	add	r3, pc
    183c:	47a8      	blx	r5
    183e:	4682      	mov	sl, r0
    1840:	6820      	ldr	r0, [r4, #0]
    1842:	4641      	mov	r1, r8
    1844:	f8d0 22c0 	ldr.w	r2, [r0, #704]	@ 0x2c0
    1848:	4620      	mov	r0, r4
    184a:	4790      	blx	r2
    184c:	4605      	mov	r5, r0
    184e:	6820      	ldr	r0, [r4, #0]
    1850:	4629      	mov	r1, r5
    1852:	2200      	movs	r2, #0
    1854:	4643      	mov	r3, r8
    1856:	f8d0 6340 	ldr.w	r6, [r0, #832]	@ 0x340
    185a:	4620      	mov	r0, r4
    185c:	f8cd 9000 	str.w	r9, [sp]
    1860:	47b0      	blx	r6
    1862:	6820      	ldr	r0, [r4, #0]
    1864:	4659      	mov	r1, fp
    1866:	4652      	mov	r2, sl
    1868:	462b      	mov	r3, r5
    186a:	f8d0 6204 	ldr.w	r6, [r0, #516]	@ 0x204
    186e:	9802      	ldr	r0, [sp, #8]
    1870:	e9cd 0800 	strd	r0, r8, [sp]
    1874:	4620      	mov	r0, r4
    1876:	47b0      	blx	r6
    1878:	6820      	ldr	r0, [r4, #0]
    187a:	4629      	mov	r1, r5
    187c:	6dc2      	ldr	r2, [r0, #92]	@ 0x5c
    187e:	4620      	mov	r0, r4
    1880:	4790      	blx	r2
    1882:	6820      	ldr	r0, [r4, #0]
    1884:	4659      	mov	r1, fp
    1886:	6dc2      	ldr	r2, [r0, #92]	@ 0x5c
    1888:	4620      	mov	r0, r4
    188a:	b003      	add	sp, #12
    188c:	e8bd 0f00 	ldmia.w	sp!, {r8, r9, sl, fp}
    1890:	e8bd 40f0 	ldmia.w	sp!, {r4, r5, r6, r7, lr}
    1894:	4710      	bx	r2
    1896:	bf00      	nop
    1898:	56be      	ldrsb	r6, [r7, r2]
    189a:	0000      	movs	r0, r0
    189c:	2e60      	cmp	r6, #96	@ 0x60
    189e:	0000      	movs	r0, r0
    18a0:	2e6f      	cmp	r6, #111	@ 0x6f
	...

000018a4 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onDestroy@@Base>:
    18a4:	b5d0      	push	{r4, r6, r7, lr}
    18a6:	af02      	add	r7, sp, #8
    18a8:	4808      	ldr	r0, [pc, #32]	@ (18cc <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onDestroy@@Base+0x28>)
    18aa:	4478      	add	r0, pc
    18ac:	6804      	ldr	r4, [r0, #0]
    18ae:	6820      	ldr	r0, [r4, #0]
    18b0:	b148      	cbz	r0, 18c6 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onDestroy@@Base+0x22>
    18b2:	f7ff ed86 	blx	13c0 <mjpeg_ndk_frame_callback_unregister@plt>
    18b6:	6820      	ldr	r0, [r4, #0]
    18b8:	f7ff ed88 	blx	13cc <mjpeg_ndk_stop@plt>
    18bc:	6820      	ldr	r0, [r4, #0]
    18be:	f7ff ed8c 	blx	13d8 <destroy_instance@plt>
    18c2:	2001      	movs	r0, #1
    18c4:	bdd0      	pop	{r4, r6, r7, pc}
    18c6:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
    18ca:	bdd0      	pop	{r4, r6, r7, pc}
    18cc:	5632      	ldrsb	r2, [r6, r0]
	...

000018d0 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_setActiveCameraIndex@@Base>:
    18d0:	4805      	ldr	r0, [pc, #20]	@ (18e8 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_setActiveCameraIndex@@Base+0x18>)
    18d2:	4478      	add	r0, pc
    18d4:	6800      	ldr	r0, [r0, #0]
    18d6:	6800      	ldr	r0, [r0, #0]
    18d8:	b110      	cbz	r0, 18e0 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_setActiveCameraIndex@@Base+0x10>
    18da:	4611      	mov	r1, r2
    18dc:	f002 bc04 	b.w	40e8 <get_ip_port@@Base+0x16b0>
    18e0:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
    18e4:	4770      	bx	lr
    18e6:	bf00      	nop
    18e8:	560a      	ldrsb	r2, [r1, r0]
	...

000018ec <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_setQPara@@Base>:
    18ec:	b5dc      	push	{r2, r3, r4, r6, r7, lr}
    18ee:	af04      	add	r7, sp, #16
    18f0:	4809      	ldr	r0, [pc, #36]	@ (1918 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_setQPara@@Base+0x2c>)
    18f2:	4478      	add	r0, pc
    18f4:	6800      	ldr	r0, [r0, #0]
    18f6:	6800      	ldr	r0, [r0, #0]
    18f8:	b150      	cbz	r0, 1910 <Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_setQPara@@Base+0x24>
    18fa:	e9d7 4102 	ldrd	r4, r1, [r7, #8]
    18fe:	b2c9      	uxtb	r1, r1
    1900:	9100      	str	r1, [sp, #0]
    1902:	b2d1      	uxtb	r1, r2
    1904:	b2da      	uxtb	r2, r3
    1906:	b2e3      	uxtb	r3, r4
    1908:	f7ff ed72 	blx	13f0 <mjpeg_ndk_set_QPara@plt>
    190c:	b002      	add	sp, #8
    190e:	bdd0      	pop	{r4, r6, r7, pc}
    1910:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
    1914:	b002      	add	sp, #8
    1916:	bdd0      	pop	{r4, r6, r7, pc}
    1918:	55ea      	strb	r2, [r5, r7]
	...

0000191c <create_instance@@Base>:
    191c:	b5f0      	push	{r4, r5, r6, r7, lr}
    191e:	af03      	add	r7, sp, #12
    1920:	e92d 0f00 	stmdb	sp!, {r8, r9, sl, fp}
    1924:	b09b      	sub	sp, #108	@ 0x6c
    1926:	e9cd 1202 	strd	r1, r2, [sp, #8]
    192a:	4606      	mov	r6, r0
    192c:	4865      	ldr	r0, [pc, #404]	@ (1ac4 <create_instance@@Base+0x1a8>)
    192e:	2401      	movs	r4, #1
    1930:	4d62      	ldr	r5, [pc, #392]	@ (1abc <create_instance@@Base+0x1a0>)
    1932:	4478      	add	r0, pc
    1934:	f105 0178 	add.w	r1, r5, #120	@ 0x78
    1938:	f8d0 b000 	ldr.w	fp, [r0]
    193c:	f8db 0000 	ldr.w	r0, [fp]
    1940:	901a      	str	r0, [sp, #104]	@ 0x68
    1942:	2001      	movs	r0, #1
    1944:	f7ff ed5a 	blx	13fc <calloc@plt>
    1948:	495f      	ldr	r1, [pc, #380]	@ (1ac8 <create_instance@@Base+0x1ac>)
    194a:	4682      	mov	sl, r0
    194c:	307c      	adds	r0, #124	@ 0x7c
    194e:	f04f 0800 	mov.w	r8, #0
    1952:	4479      	add	r1, pc
    1954:	f8d1 9000 	ldr.w	r9, [r1]
    1958:	2100      	movs	r1, #0
    195a:	47c8      	blx	r9
    195c:	4455      	add	r5, sl
    195e:	2100      	movs	r1, #0
    1960:	4628      	mov	r0, r5
    1962:	47c8      	blx	r9
    1964:	f105 0060 	add.w	r0, r5, #96	@ 0x60
    1968:	2100      	movs	r1, #0
    196a:	47c8      	blx	r9
    196c:	a804      	add	r0, sp, #16
    196e:	2100      	movs	r1, #0
    1970:	f8ca 6000 	str.w	r6, [sl]
    1974:	f885 8069 	strb.w	r8, [r5, #105]	@ 0x69
    1978:	f8ca 8070 	str.w	r8, [sl, #112]	@ 0x70
    197c:	e9c5 4806 	strd	r4, r8, [r5, #24]
    1980:	f8c5 8028 	str.w	r8, [r5, #40]	@ 0x28
    1984:	f7ff ed40 	blx	1408 <gettimeofday@plt>
    1988:	e9dd 0104 	ldrd	r0, r1, [sp, #16]
    198c:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
    1990:	e9c5 010e 	strd	r0, r1, [r5, #56]	@ 0x38
    1994:	aa09      	add	r2, sp, #36	@ 0x24
    1996:	e9c5 0101 	strd	r0, r1, [r5, #4]
    199a:	ab08      	add	r3, sp, #32
    199c:	e9c5 0111 	strd	r0, r1, [r5, #68]	@ 0x44
    19a0:	f105 0050 	add.w	r0, r5, #80	@ 0x50
    19a4:	f8cd 8040 	str.w	r8, [sp, #64]	@ 0x40
    19a8:	2100      	movs	r1, #0
    19aa:	f940 0acf 	vst1.64	{d16-d17}, [r0]
    19ae:	4844      	ldr	r0, [pc, #272]	@ (1ac0 <create_instance@@Base+0x1a4>)
    19b0:	f885 8068 	strb.w	r8, [r5, #104]	@ 0x68
    19b4:	6668      	str	r0, [r5, #100]	@ 0x64
    19b6:	f102 000c 	add.w	r0, r2, #12
    19ba:	f940 0a8f 	vst1.32	{d16-d17}, [r0]
    19be:	2002      	movs	r0, #2
    19c0:	900b      	str	r0, [sp, #44]	@ 0x2c
    19c2:	e9cd 4009 	strd	r4, r0, [sp, #36]	@ 0x24
    19c6:	4841      	ldr	r0, [pc, #260]	@ (1acc <create_instance@@Base+0x1b0>)
    19c8:	4478      	add	r0, pc
    19ca:	f7ff ed24 	blx	1414 <getaddrinfo@plt>
    19ce:	2800      	cmp	r0, #0
    19d0:	d171      	bne.n	1ab6 <create_instance@@Base+0x19a>
    19d2:	9a08      	ldr	r2, [sp, #32]
    19d4:	3204      	adds	r2, #4
    19d6:	ca07      	ldmia	r2, {r0, r1, r2}
    19d8:	f7ff ed22 	blx	1420 <socket@plt>
    19dc:	4606      	mov	r6, r0
    19de:	2008      	movs	r0, #8
    19e0:	ab06      	add	r3, sp, #24
    19e2:	9000      	str	r0, [sp, #0]
    19e4:	4630      	mov	r0, r6
    19e6:	2101      	movs	r1, #1
    19e8:	2214      	movs	r2, #20
    19ea:	e9cd 4806 	strd	r4, r8, [sp, #24]
    19ee:	f7ff ed1e 	blx	142c <setsockopt@plt>
    19f2:	3001      	adds	r0, #1
    19f4:	d056      	beq.n	1aa4 <create_instance@@Base+0x188>
    19f6:	9808      	ldr	r0, [sp, #32]
    19f8:	6902      	ldr	r2, [r0, #16]
    19fa:	6981      	ldr	r1, [r0, #24]
    19fc:	4630      	mov	r0, r6
    19fe:	f7ff ed1c 	blx	1438 <bind@plt>
    1a02:	2800      	cmp	r0, #0
    1a04:	d153      	bne.n	1aae <create_instance@@Base+0x192>
    1a06:	ac12      	add	r4, sp, #72	@ 0x48
    1a08:	2010      	movs	r0, #16
    1a0a:	aa11      	add	r2, sp, #68	@ 0x44
    1a0c:	9011      	str	r0, [sp, #68]	@ 0x44
    1a0e:	4630      	mov	r0, r6
    1a10:	4621      	mov	r1, r4
    1a12:	f8ca 6004 	str.w	r6, [sl, #4]
    1a16:	f7ff ed16 	blx	1444 <getsockname@plt>
    1a1a:	efc0 0050 	vmov.i32	q8, #0	@ 0x00000000
    1a1e:	f104 0010 	add.w	r0, r4, #16
    1a22:	4621      	mov	r1, r4
    1a24:	ab11      	add	r3, sp, #68	@ 0x44
    1a26:	4622      	mov	r2, r4
    1a28:	f940 0acf 	vst1.64	{d16-d17}, [r0]
    1a2c:	2008      	movs	r0, #8
    1a2e:	f941 0ac0 	vst1.64	{d16-d17}, [r1], r0
    1a32:	2002      	movs	r0, #2
    1a34:	6008      	str	r0, [r1, #0]
    1a36:	9013      	str	r0, [sp, #76]	@ 0x4c
    1a38:	e9dd 0102 	ldrd	r0, r1, [sp, #8]
    1a3c:	f7ff ecea 	blx	1414 <getaddrinfo@plt>
    1a40:	b948      	cbnz	r0, 1a56 <create_instance@@Base+0x13a>
    1a42:	9811      	ldr	r0, [sp, #68]	@ 0x44
    1a44:	f10a 0108 	add.w	r1, sl, #8
    1a48:	6982      	ldr	r2, [r0, #24]
    1a4a:	f962 0a4f 	vld1.16	{d16-d17}, [r2]
    1a4e:	f941 0a4f 	vst1.16	{d16-d17}, [r1]
    1a52:	f7ff ecfe 	blx	1450 <freeaddrinfo@plt>
    1a56:	4920      	ldr	r1, [pc, #128]	@ (1ad8 <create_instance@@Base+0x1bc>)
    1a58:	f105 002c 	add.w	r0, r5, #44	@ 0x2c
    1a5c:	4653      	mov	r3, sl
    1a5e:	4479      	add	r1, pc
    1a60:	680a      	ldr	r2, [r1, #0]
    1a62:	491e      	ldr	r1, [pc, #120]	@ (1adc <create_instance@@Base+0x1c0>)
    1a64:	4479      	add	r1, pc
    1a66:	680c      	ldr	r4, [r1, #0]
    1a68:	2100      	movs	r1, #0
    1a6a:	47a0      	blx	r4
    1a6c:	491c      	ldr	r1, [pc, #112]	@ (1ae0 <create_instance@@Base+0x1c4>)
    1a6e:	f105 0030 	add.w	r0, r5, #48	@ 0x30
    1a72:	4653      	mov	r3, sl
    1a74:	4479      	add	r1, pc
    1a76:	680a      	ldr	r2, [r1, #0]
    1a78:	2100      	movs	r1, #0
    1a7a:	47a0      	blx	r4
    1a7c:	4919      	ldr	r1, [pc, #100]	@ (1ae4 <create_instance@@Base+0x1c8>)
    1a7e:	f105 0034 	add.w	r0, r5, #52	@ 0x34
    1a82:	4653      	mov	r3, sl
    1a84:	4479      	add	r1, pc
    1a86:	680a      	ldr	r2, [r1, #0]
    1a88:	2100      	movs	r1, #0
    1a8a:	47a0      	blx	r4
    1a8c:	f8db 0000 	ldr.w	r0, [fp]
    1a90:	991a      	ldr	r1, [sp, #104]	@ 0x68
    1a92:	1a40      	subs	r0, r0, r1
    1a94:	bf01      	itttt	eq
    1a96:	4650      	moveq	r0, sl
    1a98:	b01b      	addeq	sp, #108	@ 0x6c
    1a9a:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    1a9e:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    1aa0:	f7ff ec88 	blx	13b4 <__stack_chk_fail@plt>
    1aa4:	480a      	ldr	r0, [pc, #40]	@ (1ad0 <create_instance@@Base+0x1b4>)
    1aa6:	4478      	add	r0, pc
    1aa8:	f7ff ecd8 	blx	145c <perror@plt>
    1aac:	e7a3      	b.n	19f6 <create_instance@@Base+0xda>
    1aae:	4809      	ldr	r0, [pc, #36]	@ (1ad4 <create_instance@@Base+0x1b8>)
    1ab0:	4478      	add	r0, pc
    1ab2:	f7ff ecd4 	blx	145c <perror@plt>
    1ab6:	2001      	movs	r0, #1
    1ab8:	f7ff ecd6 	blx	1468 <exit@plt>
    1abc:	0398      	lsls	r0, r3, #14
    1abe:	0070      	lsls	r0, r6, #1
    1ac0:	4b0a      	ldr	r3, [pc, #40]	@ (1aec <thread_timer@@Base+0x4>)
    1ac2:	2d14      	cmp	r5, #20
    1ac4:	559e      	strb	r6, [r3, r6]
    1ac6:	0000      	movs	r0, r0
    1ac8:	5592      	strb	r2, [r2, r6]
    1aca:	0000      	movs	r0, r0
    1acc:	2ce9      	cmp	r4, #233	@ 0xe9
    1ace:	0000      	movs	r0, r0
    1ad0:	2c13      	cmp	r4, #19
    1ad2:	0000      	movs	r0, r0
    1ad4:	2c1c      	cmp	r4, #28
    1ad6:	0000      	movs	r0, r0
    1ad8:	548a      	strb	r2, [r1, r2]
    1ada:	0000      	movs	r0, r0
    1adc:	5488      	strb	r0, [r1, r2]
    1ade:	0000      	movs	r0, r0
    1ae0:	547c      	strb	r4, [r7, r1]
    1ae2:	0000      	movs	r0, r0
    1ae4:	5470      	strb	r0, [r6, r1]
	...

00001ae8 <thread_timer@@Base>:
    1ae8:	b5f0      	push	{r4, r5, r6, r7, lr}
    1aea:	af03      	add	r7, sp, #12
    1aec:	e92d 0f80 	stmdb	sp!, {r7, r8, r9, sl, fp}
    1af0:	ed2d 8b08 	vpush	{d8-d11}
    1af4:	b09c      	sub	sp, #112	@ 0x70
    1af6:	4604      	mov	r4, r0
    1af8:	48a7      	ldr	r0, [pc, #668]	@ (1d98 <thread_timer@@Base+0x2b0>)
    1afa:	ef80 8050 	vmov.i32	q4, #0	@ 0x00000000
    1afe:	f104 0674 	add.w	r6, r4, #116	@ 0x74
    1b02:	4478      	add	r0, pc
    1b04:	ad18      	add	r5, sp, #96	@ 0x60
    1b06:	f04f 0800 	mov.w	r8, #0
    1b0a:	6800      	ldr	r0, [r0, #0]
    1b0c:	9003      	str	r0, [sp, #12]
    1b0e:	6800      	ldr	r0, [r0, #0]
    1b10:	901b      	str	r0, [sp, #108]	@ 0x6c
    1b12:	489d      	ldr	r0, [pc, #628]	@ (1d88 <thread_timer@@Base+0x2a0>)
    1b14:	9616      	str	r6, [sp, #88]	@ 0x58
    1b16:	eb04 0a00 	add.w	sl, r4, r0
    1b1a:	f10a 0150 	add.w	r1, sl, #80	@ 0x50
    1b1e:	9114      	str	r1, [sp, #80]	@ 0x50
    1b20:	f10a 0110 	add.w	r1, sl, #16
    1b24:	9113      	str	r1, [sp, #76]	@ 0x4c
    1b26:	f104 0108 	add.w	r1, r4, #8
    1b2a:	9105      	str	r1, [sp, #20]
    1b2c:	f100 0168 	add.w	r1, r0, #104	@ 0x68
    1b30:	9112      	str	r1, [sp, #72]	@ 0x48
    1b32:	f100 0167 	add.w	r1, r0, #103	@ 0x67
    1b36:	9111      	str	r1, [sp, #68]	@ 0x44
    1b38:	f100 0166 	add.w	r1, r0, #102	@ 0x66
    1b3c:	9110      	str	r1, [sp, #64]	@ 0x40
    1b3e:	f100 0165 	add.w	r1, r0, #101	@ 0x65
    1b42:	910f      	str	r1, [sp, #60]	@ 0x3c
    1b44:	f100 0164 	add.w	r1, r0, #100	@ 0x64
    1b48:	910e      	str	r1, [sp, #56]	@ 0x38
    1b4a:	f100 0158 	add.w	r1, r0, #88	@ 0x58
    1b4e:	9104      	str	r1, [sp, #16]
    1b50:	1d01      	adds	r1, r0, #4
    1b52:	910d      	str	r1, [sp, #52]	@ 0x34
    1b54:	f100 0120 	add.w	r1, r0, #32
    1b58:	910c      	str	r1, [sp, #48]	@ 0x30
    1b5a:	498c      	ldr	r1, [pc, #560]	@ (1d8c <thread_timer@@Base+0x2a4>)
    1b5c:	f10a 0b44 	add.w	fp, sl, #68	@ 0x44
    1b60:	f10a 0938 	add.w	r9, sl, #56	@ 0x38
    1b64:	f101 0288 	add.w	r2, r1, #136	@ 0x88
    1b68:	920b      	str	r2, [sp, #44]	@ 0x2c
    1b6a:	f101 0284 	add.w	r2, r1, #132	@ 0x84
    1b6e:	3180      	adds	r1, #128	@ 0x80
    1b70:	9109      	str	r1, [sp, #36]	@ 0x24
    1b72:	f104 0180 	add.w	r1, r4, #128	@ 0x80
    1b76:	9108      	str	r1, [sp, #32]
    1b78:	f104 0120 	add.w	r1, r4, #32
    1b7c:	9107      	str	r1, [sp, #28]
    1b7e:	f100 0128 	add.w	r1, r0, #40	@ 0x28
    1b82:	3069      	adds	r0, #105	@ 0x69
    1b84:	9015      	str	r0, [sp, #84]	@ 0x54
    1b86:	a07c      	add	r0, pc, #496	@ (adr r0, 1d78 <thread_timer@@Base+0x290>)
    1b88:	920a      	str	r2, [sp, #40]	@ 0x28
    1b8a:	f920 aacf 	vld1.64	{d10-d11}, [r0]
    1b8e:	9106      	str	r1, [sp, #24]
    1b90:	e9d4 1006 	ldrd	r1, r0, [r4, #24]
    1b94:	2900      	cmp	r1, #0
    1b96:	f000 808d 	beq.w	1cb4 <thread_timer@@Base+0x1cc>
    1b9a:	2800      	cmp	r0, #0
    1b9c:	f040 80db 	bne.w	1d56 <thread_timer@@Base+0x26e>
    1ba0:	f44f 707a 	mov.w	r0, #1000	@ 0x3e8
    1ba4:	f7ff ec66 	blx	1474 <usleep@plt>
    1ba8:	4628      	mov	r0, r5
    1baa:	2100      	movs	r1, #0
    1bac:	f7ff ec2c 	blx	1408 <gettimeofday@plt>
    1bb0:	6f20      	ldr	r0, [r4, #112]	@ 0x70
    1bb2:	2800      	cmp	r0, #0
    1bb4:	f000 8084 	beq.w	1cc0 <thread_timer@@Base+0x1d8>
    1bb8:	4630      	mov	r0, r6
    1bba:	4629      	mov	r1, r5
    1bbc:	f7ff ec60 	blx	1480 <time_interval_ms@plt>
    1bc0:	f5b0 7f7a 	cmp.w	r0, #1000	@ 0x3e8
    1bc4:	dd0d      	ble.n	1be2 <thread_timer@@Base+0xfa>
    1bc6:	9915      	ldr	r1, [sp, #84]	@ 0x54
    1bc8:	5c60      	ldrb	r0, [r4, r1]
    1bca:	1e43      	subs	r3, r0, #1
    1bcc:	f04f 0003 	mov.w	r0, #3
    1bd0:	bf18      	it	ne
    1bd2:	2301      	movne	r3, #1
    1bd4:	5463      	strb	r3, [r4, r1]
    1bd6:	4973      	ldr	r1, [pc, #460]	@ (1da4 <thread_timer@@Base+0x2bc>)
    1bd8:	4a73      	ldr	r2, [pc, #460]	@ (1da8 <thread_timer@@Base+0x2c0>)
    1bda:	4479      	add	r1, pc
    1bdc:	447a      	add	r2, pc
    1bde:	f7ff ec56 	blx	148c <__android_log_print@plt>
    1be2:	6f20      	ldr	r0, [r4, #112]	@ 0x70
    1be4:	2800      	cmp	r0, #0
    1be6:	f000 808d 	beq.w	1d04 <thread_timer@@Base+0x21c>
    1bea:	4630      	mov	r0, r6
    1bec:	4629      	mov	r1, r5
    1bee:	f7ff ec48 	blx	1480 <time_interval_ms@plt>
    1bf2:	f5b0 6ffa 	cmp.w	r0, #2000	@ 0x7d0
    1bf6:	f340 8085 	ble.w	1d04 <thread_timer@@Base+0x21c>
    1bfa:	496c      	ldr	r1, [pc, #432]	@ (1dac <thread_timer@@Base+0x2c4>)
    1bfc:	2003      	movs	r0, #3
    1bfe:	4a6c      	ldr	r2, [pc, #432]	@ (1db0 <thread_timer@@Base+0x2c8>)
    1c00:	4479      	add	r1, pc
    1c02:	447a      	add	r2, pc
    1c04:	f7ff ec42 	blx	148c <__android_log_print@plt>
    1c08:	f44f 7096 	mov.w	r0, #300	@ 0x12c
    1c0c:	f8c4 8018 	str.w	r8, [r4, #24]
    1c10:	f7ff ec30 	blx	1474 <usleep@plt>
    1c14:	9907      	ldr	r1, [sp, #28]
    1c16:	9e06      	ldr	r6, [sp, #24]
    1c18:	f101 0020 	add.w	r0, r1, #32
    1c1c:	f8c4 8070 	str.w	r8, [r4, #112]	@ 0x70
    1c20:	f844 8006 	str.w	r8, [r4, r6]
    1c24:	f900 8a0f 	vst1.8	{d8-d9}, [r0]
    1c28:	f101 0010 	add.w	r0, r1, #16
    1c2c:	f900 8a0f 	vst1.8	{d8-d9}, [r0]
    1c30:	4608      	mov	r0, r1
    1c32:	2130      	movs	r1, #48	@ 0x30
    1c34:	f900 8a01 	vst1.8	{d8-d9}, [r0], r1
    1c38:	f900 8a0f 	vst1.8	{d8-d9}, [r0]
    1c3c:	9808      	ldr	r0, [sp, #32]
    1c3e:	4953      	ldr	r1, [pc, #332]	@ (1d8c <thread_timer@@Base+0x2a4>)
    1c40:	f8c4 806c 	str.w	r8, [r4, #108]	@ 0x6c
    1c44:	f7ff ec28 	blx	1498 <__aeabi_memclr@plt>
    1c48:	9809      	ldr	r0, [sp, #36]	@ 0x24
    1c4a:	f844 8000 	str.w	r8, [r4, r0]
    1c4e:	980a      	ldr	r0, [sp, #40]	@ 0x28
    1c50:	f844 8000 	str.w	r8, [r4, r0]
    1c54:	980b      	ldr	r0, [sp, #44]	@ 0x2c
    1c56:	f844 8000 	str.w	r8, [r4, r0]
    1c5a:	9813      	ldr	r0, [sp, #76]	@ 0x4c
    1c5c:	f900 aacf 	vst1.64	{d10-d11}, [r0]
    1c60:	980c      	ldr	r0, [sp, #48]	@ 0x30
    1c62:	f844 8000 	str.w	r8, [r4, r0]
    1c66:	4420      	add	r0, r4
    1c68:	f8c0 8004 	str.w	r8, [r0, #4]
    1c6c:	f844 8006 	str.w	r8, [r4, r6]
    1c70:	e9dd 0118 	ldrd	r0, r1, [sp, #96]	@ 0x60
    1c74:	9e16      	ldr	r6, [sp, #88]	@ 0x58
    1c76:	e9c9 0100 	strd	r0, r1, [r9]
    1c7a:	9a0d      	ldr	r2, [sp, #52]	@ 0x34
    1c7c:	50a0      	str	r0, [r4, r2]
    1c7e:	4422      	add	r2, r4
    1c80:	6051      	str	r1, [r2, #4]
    1c82:	e9cb 0100 	strd	r0, r1, [fp]
    1c86:	210a      	movs	r1, #10
    1c88:	9814      	ldr	r0, [sp, #80]	@ 0x50
    1c8a:	f900 8acf 	vst1.64	{d8-d9}, [r0]
    1c8e:	980e      	ldr	r0, [sp, #56]	@ 0x38
    1c90:	5421      	strb	r1, [r4, r0]
    1c92:	214b      	movs	r1, #75	@ 0x4b
    1c94:	980f      	ldr	r0, [sp, #60]	@ 0x3c
    1c96:	5421      	strb	r1, [r4, r0]
    1c98:	2114      	movs	r1, #20
    1c9a:	9810      	ldr	r0, [sp, #64]	@ 0x40
    1c9c:	5421      	strb	r1, [r4, r0]
    1c9e:	212d      	movs	r1, #45	@ 0x2d
    1ca0:	9811      	ldr	r0, [sp, #68]	@ 0x44
    1ca2:	5421      	strb	r1, [r4, r0]
    1ca4:	9812      	ldr	r0, [sp, #72]	@ 0x48
    1ca6:	f804 8000 	strb.w	r8, [r4, r0]
    1caa:	2001      	movs	r0, #1
    1cac:	61a0      	str	r0, [r4, #24]
    1cae:	f8c4 806c 	str.w	r8, [r4, #108]	@ 0x6c
    1cb2:	e76d      	b.n	1b90 <thread_timer@@Base+0xa8>
    1cb4:	2801      	cmp	r0, #1
    1cb6:	d04e      	beq.n	1d56 <thread_timer@@Base+0x26e>
    1cb8:	4836      	ldr	r0, [pc, #216]	@ (1d94 <thread_timer@@Base+0x2ac>)
    1cba:	f7ff ebdc 	blx	1474 <usleep@plt>
    1cbe:	e767      	b.n	1b90 <thread_timer@@Base+0xa8>
    1cc0:	4648      	mov	r0, r9
    1cc2:	4629      	mov	r1, r5
    1cc4:	f7ff ebdc 	blx	1480 <time_interval_ms@plt>
    1cc8:	2865      	cmp	r0, #101	@ 0x65
    1cca:	db17      	blt.n	1cfc <thread_timer@@Base+0x214>
    1ccc:	4933      	ldr	r1, [pc, #204]	@ (1d9c <thread_timer@@Base+0x2b4>)
    1cce:	2003      	movs	r0, #3
    1cd0:	4a33      	ldr	r2, [pc, #204]	@ (1da0 <thread_timer@@Base+0x2b8>)
    1cd2:	4479      	add	r1, pc
    1cd4:	447a      	add	r2, pc
    1cd6:	f7ff ebda 	blx	148c <__android_log_print@plt>
    1cda:	e9dd 0118 	ldrd	r0, r1, [sp, #96]	@ 0x60
    1cde:	2204      	movs	r2, #4
    1ce0:	e9c9 0100 	strd	r0, r1, [r9]
    1ce4:	2300      	movs	r3, #0
    1ce6:	482a      	ldr	r0, [pc, #168]	@ (1d90 <thread_timer@@Base+0x2a8>)
    1ce8:	9017      	str	r0, [sp, #92]	@ 0x5c
    1cea:	9905      	ldr	r1, [sp, #20]
    1cec:	6860      	ldr	r0, [r4, #4]
    1cee:	9100      	str	r1, [sp, #0]
    1cf0:	2110      	movs	r1, #16
    1cf2:	9101      	str	r1, [sp, #4]
    1cf4:	a917      	add	r1, sp, #92	@ 0x5c
    1cf6:	f7ff ebd6 	blx	14a4 <sendto@plt>
    1cfa:	e749      	b.n	1b90 <thread_timer@@Base+0xa8>
    1cfc:	6f20      	ldr	r0, [r4, #112]	@ 0x70
    1cfe:	2800      	cmp	r0, #0
    1d00:	f47f af5a 	bne.w	1bb8 <thread_timer@@Base+0xd0>
    1d04:	4650      	mov	r0, sl
    1d06:	f7ff ebd4 	blx	14b0 <pthread_mutex_lock@plt>
    1d0a:	6f20      	ldr	r0, [r4, #112]	@ 0x70
    1d0c:	b1f8      	cbz	r0, 1d4e <thread_timer@@Base+0x266>
    1d0e:	4658      	mov	r0, fp
    1d10:	4629      	mov	r1, r5
    1d12:	f7ff ebb6 	blx	1480 <time_interval_ms@plt>
    1d16:	2819      	cmp	r0, #25
    1d18:	db19      	blt.n	1d4e <thread_timer@@Base+0x266>
    1d1a:	9804      	ldr	r0, [sp, #16]
    1d1c:	465e      	mov	r6, fp
    1d1e:	46d3      	mov	fp, sl
    1d20:	46ca      	mov	sl, r9
    1d22:	4629      	mov	r1, r5
    1d24:	f854 9000 	ldr.w	r9, [r4, r0]
    1d28:	9816      	ldr	r0, [sp, #88]	@ 0x58
    1d2a:	f7ff ebaa 	blx	1480 <time_interval_ms@plt>
    1d2e:	2813      	cmp	r0, #19
    1d30:	bfc8      	it	gt
    1d32:	f06f 0901 	mvngt.w	r9, #1
    1d36:	4649      	mov	r1, r9
    1d38:	4620      	mov	r0, r4
    1d3a:	46d1      	mov	r9, sl
    1d3c:	46da      	mov	sl, fp
    1d3e:	46b3      	mov	fp, r6
    1d40:	9e16      	ldr	r6, [sp, #88]	@ 0x58
    1d42:	f7ff ebbc 	blx	14bc <build_send_ack@plt>
    1d46:	e9dd 0118 	ldrd	r0, r1, [sp, #96]	@ 0x60
    1d4a:	e9cb 0100 	strd	r0, r1, [fp]
    1d4e:	4650      	mov	r0, sl
    1d50:	f7ff ebba 	blx	14c8 <pthread_mutex_unlock@plt>
    1d54:	e71c      	b.n	1b90 <thread_timer@@Base+0xa8>
    1d56:	9803      	ldr	r0, [sp, #12]
    1d58:	6800      	ldr	r0, [r0, #0]
    1d5a:	991b      	ldr	r1, [sp, #108]	@ 0x6c
    1d5c:	1a40      	subs	r0, r0, r1
    1d5e:	bf01      	itttt	eq
    1d60:	2001      	moveq	r0, #1
    1d62:	b01c      	addeq	sp, #112	@ 0x70
    1d64:	ecbd 8b08 	vpopeq	{d8-d11}
    1d68:	b001      	addeq	sp, #4
    1d6a:	bf04      	itt	eq
    1d6c:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    1d70:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    1d72:	f7ff eb20 	blx	13b4 <__stack_chk_fail@plt>
    1d76:	bf00      	nop
	...
    1d80:	0001      	movs	r1, r0
    1d82:	0000      	movs	r0, r0
    1d84:	0000      	movs	r0, r0
    1d86:	0000      	movs	r0, r0
    1d88:	0398      	lsls	r0, r3, #14
    1d8a:	0070      	lsls	r0, r6, #1
    1d8c:	02c0      	lsls	r0, r0, #11
    1d8e:	0040      	lsls	r0, r0, #1
    1d90:	00ef      	lsls	r7, r5, #3
    1d92:	0004      	movs	r4, r0
    1d94:	86a0      	strh	r0, [r4, #52]	@ 0x34
    1d96:	0001      	movs	r1, r0
    1d98:	53ce      	strh	r6, [r1, r7]
    1d9a:	0000      	movs	r0, r0
    1d9c:	2a01      	cmp	r2, #1
    1d9e:	0000      	movs	r0, r0
    1da0:	2a05      	cmp	r2, #5
    1da2:	0000      	movs	r0, r0
    1da4:	2af9      	cmp	r2, #249	@ 0xf9
    1da6:	0000      	movs	r0, r0
    1da8:	2b20      	cmp	r3, #32
    1daa:	0000      	movs	r0, r0
    1dac:	2ad3      	cmp	r2, #211	@ 0xd3
    1dae:	0000      	movs	r0, r0
    1db0:	2b12      	cmp	r3, #18
	...

00001db4 <thread_ctl@@Base>:
    1db4:	b5f0      	push	{r4, r5, r6, r7, lr}
    1db6:	af03      	add	r7, sp, #12
    1db8:	e92d 0f00 	stmdb	sp!, {r8, r9, sl, fp}
    1dbc:	b08f      	sub	sp, #60	@ 0x3c
    1dbe:	4604      	mov	r4, r0
    1dc0:	4852      	ldr	r0, [pc, #328]	@ (1f0c <thread_ctl@@Base+0x158>)
    1dc2:	2200      	movs	r2, #0
    1dc4:	4478      	add	r0, pc
    1dc6:	6805      	ldr	r5, [r0, #0]
    1dc8:	6828      	ldr	r0, [r5, #0]
    1dca:	900e      	str	r0, [sp, #56]	@ 0x38
    1dcc:	4850      	ldr	r0, [pc, #320]	@ (1f10 <thread_ctl@@Base+0x15c>)
    1dce:	4478      	add	r0, pc
    1dd0:	6800      	ldr	r0, [r0, #0]
    1dd2:	6800      	ldr	r0, [r0, #0]
    1dd4:	6801      	ldr	r1, [r0, #0]
    1dd6:	690b      	ldr	r3, [r1, #16]
    1dd8:	a907      	add	r1, sp, #28
    1dda:	4798      	blx	r3
    1ddc:	f1b0 3fff 	cmp.w	r0, #4294967295	@ 0xffffffff
    1de0:	dd7b      	ble.n	1eda <thread_ctl@@Base+0x126>
    1de2:	4844      	ldr	r0, [pc, #272]	@ (1ef4 <thread_ctl@@Base+0x140>)
    1de4:	9501      	str	r5, [sp, #4]
    1de6:	1825      	adds	r5, r4, r0
    1de8:	4943      	ldr	r1, [pc, #268]	@ (1ef8 <thread_ctl@@Base+0x144>)
    1dea:	9807      	ldr	r0, [sp, #28]
    1dec:	6728      	str	r0, [r5, #112]	@ 0x70
    1dee:	1860      	adds	r0, r4, r1
    1df0:	f100 0a10 	add.w	sl, r0, #16
    1df4:	a808      	add	r0, sp, #32
    1df6:	f100 0909 	add.w	r9, r0, #9
    1dfa:	f101 0808 	add.w	r8, r1, #8
    1dfe:	69a0      	ldr	r0, [r4, #24]
    1e00:	2800      	cmp	r0, #0
    1e02:	d063      	beq.n	1ecc <thread_ctl@@Base+0x118>
    1e04:	6f20      	ldr	r0, [r4, #112]	@ 0x70
    1e06:	2800      	cmp	r0, #0
    1e08:	d060      	beq.n	1ecc <thread_ctl@@Base+0x118>
    1e0a:	69e0      	ldr	r0, [r4, #28]
    1e0c:	2800      	cmp	r0, #0
    1e0e:	d165      	bne.n	1edc <thread_ctl@@Base+0x128>
    1e10:	f249 4070 	movw	r0, #38000	@ 0x9470
    1e14:	f7ff eb2e 	blx	1474 <usleep@plt>
    1e18:	69e0      	ldr	r0, [r4, #28]
    1e1a:	2800      	cmp	r0, #0
    1e1c:	d15e      	bne.n	1edc <thread_ctl@@Base+0x128>
    1e1e:	4628      	mov	r0, r5
    1e20:	f7ff eb46 	blx	14b0 <pthread_mutex_lock@plt>
    1e24:	f854 0008 	ldr.w	r0, [r4, r8]
    1e28:	2801      	cmp	r0, #1
    1e2a:	da10      	bge.n	1e4e <thread_ctl@@Base+0x9a>
    1e2c:	4628      	mov	r0, r5
    1e2e:	f7ff eb4c 	blx	14c8 <pthread_mutex_unlock@plt>
    1e32:	f644 2038 	movw	r0, #19000	@ 0x4a38
    1e36:	f7ff eb1e 	blx	1474 <usleep@plt>
    1e3a:	69e0      	ldr	r0, [r4, #28]
    1e3c:	2800      	cmp	r0, #0
    1e3e:	d14d      	bne.n	1edc <thread_ctl@@Base+0x128>
    1e40:	4628      	mov	r0, r5
    1e42:	f7ff eb36 	blx	14b0 <pthread_mutex_lock@plt>
    1e46:	f854 0008 	ldr.w	r0, [r4, r8]
    1e4a:	2801      	cmp	r0, #1
    1e4c:	db3a      	blt.n	1ec4 <thread_ctl@@Base+0x110>
    1e4e:	ae02      	add	r6, sp, #8
    1e50:	2100      	movs	r1, #0
    1e52:	4630      	mov	r0, r6
    1e54:	f7ff ead8 	blx	1408 <gettimeofday@plt>
    1e58:	a804      	add	r0, sp, #16
    1e5a:	4631      	mov	r1, r6
    1e5c:	4e26      	ldr	r6, [pc, #152]	@ (1ef8 <thread_ctl@@Base+0x144>)
    1e5e:	f7ff eb10 	blx	1480 <time_interval_ms@plt>
    1e62:	f854 0008 	ldr.w	r0, [r4, r8]
    1e66:	f854 b006 	ldr.w	fp, [r4, r6]
    1e6a:	3801      	subs	r0, #1
    1e6c:	f844 0008 	str.w	r0, [r4, r8]
    1e70:	e9dd 0102 	ldrd	r0, r1, [sp, #8]
    1e74:	e9cd 0104 	strd	r0, r1, [sp, #16]
    1e78:	4820      	ldr	r0, [pc, #128]	@ (1efc <thread_ctl@@Base+0x148>)
    1e7a:	4601      	mov	r1, r0
    1e7c:	fb0b f000 	mul.w	r0, fp, r0
    1e80:	fb0b a201 	mla	r2, fp, r1, sl
    1e84:	f85a 0000 	ldr.w	r0, [sl, r0]
    1e88:	6851      	ldr	r1, [r2, #4]
    1e8a:	9109      	str	r1, [sp, #36]	@ 0x24
    1e8c:	9008      	str	r0, [sp, #32]
    1e8e:	7b10      	ldrb	r0, [r2, #12]
    1e90:	f88d 0028 	strb.w	r0, [sp, #40]	@ 0x28
    1e94:	481a      	ldr	r0, [pc, #104]	@ (1f00 <thread_ctl@@Base+0x14c>)
    1e96:	5810      	ldr	r0, [r2, r0]
    1e98:	f8c9 0007 	str.w	r0, [r9, #7]
    1e9c:	4819      	ldr	r0, [pc, #100]	@ (1f04 <thread_ctl@@Base+0x150>)
    1e9e:	4410      	add	r0, r2
    1ea0:	f960 070f 	vld1.8	{d16}, [r0]
    1ea4:	9807      	ldr	r0, [sp, #28]
    1ea6:	f949 070f 	vst1.8	{d16}, [r9]
    1eaa:	900d      	str	r0, [sp, #52]	@ 0x34
    1eac:	f102 000d 	add.w	r0, r2, #13
    1eb0:	6891      	ldr	r1, [r2, #8]
    1eb2:	aa08      	add	r2, sp, #32
    1eb4:	6e23      	ldr	r3, [r4, #96]	@ 0x60
    1eb6:	4798      	blx	r3
    1eb8:	f10b 0001 	add.w	r0, fp, #1
    1ebc:	2103      	movs	r1, #3
    1ebe:	f002 f8ff 	bl	40c0 <get_ip_port@@Base+0x1688>
    1ec2:	51a1      	str	r1, [r4, r6]
    1ec4:	4628      	mov	r0, r5
    1ec6:	f7ff eb00 	blx	14c8 <pthread_mutex_unlock@plt>
    1eca:	e798      	b.n	1dfe <thread_ctl@@Base+0x4a>
    1ecc:	69e0      	ldr	r0, [r4, #28]
    1ece:	2801      	cmp	r0, #1
    1ed0:	d004      	beq.n	1edc <thread_ctl@@Base+0x128>
    1ed2:	480d      	ldr	r0, [pc, #52]	@ (1f08 <thread_ctl@@Base+0x154>)
    1ed4:	f7ff eace 	blx	1474 <usleep@plt>
    1ed8:	e791      	b.n	1dfe <thread_ctl@@Base+0x4a>
    1eda:	e7fe      	b.n	1eda <thread_ctl@@Base+0x126>
    1edc:	9801      	ldr	r0, [sp, #4]
    1ede:	6800      	ldr	r0, [r0, #0]
    1ee0:	990e      	ldr	r1, [sp, #56]	@ 0x38
    1ee2:	1a40      	subs	r0, r0, r1
    1ee4:	bf01      	itttt	eq
    1ee6:	2001      	moveq	r0, #1
    1ee8:	b00f      	addeq	sp, #60	@ 0x3c
    1eea:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    1eee:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    1ef0:	f7ff ea60 	blx	13b4 <__stack_chk_fail@plt>
    1ef4:	0398      	lsls	r0, r3, #14
    1ef6:	0070      	lsls	r0, r6, #1
    1ef8:	0340      	lsls	r0, r0, #13
    1efa:	0040      	lsls	r0, r0, #1
    1efc:	0018      	movs	r0, r3
    1efe:	0010      	movs	r0, r2
    1f00:	0014      	movs	r4, r2
    1f02:	0010      	movs	r0, r2
    1f04:	000d      	movs	r5, r1
    1f06:	0010      	movs	r0, r2
    1f08:	86a0      	strh	r0, [r4, #52]	@ 0x34
    1f0a:	0001      	movs	r1, r0
    1f0c:	510c      	str	r4, [r1, r4]
    1f0e:	0000      	movs	r0, r0
    1f10:	5106      	str	r6, [r0, r4]
	...

00001f14 <thread_recv@@Base>:
    1f14:	b5f0      	push	{r4, r5, r6, r7, lr}
    1f16:	af03      	add	r7, sp, #12
    1f18:	e92d 0700 	stmdb	sp!, {r8, r9, sl}
    1f1c:	f5ad 6d8a 	sub.w	sp, sp, #1104	@ 0x450
    1f20:	4604      	mov	r4, r0
    1f22:	483c      	ldr	r0, [pc, #240]	@ (2014 <thread_recv@@Base+0x100>)
    1f24:	2200      	movs	r2, #0
    1f26:	4478      	add	r0, pc
    1f28:	f8d0 8000 	ldr.w	r8, [r0]
    1f2c:	f8d8 0000 	ldr.w	r0, [r8]
    1f30:	f847 0c1c 	str.w	r0, [r7, #-28]
    1f34:	4838      	ldr	r0, [pc, #224]	@ (2018 <thread_recv@@Base+0x104>)
    1f36:	4478      	add	r0, pc
    1f38:	6800      	ldr	r0, [r0, #0]
    1f3a:	6800      	ldr	r0, [r0, #0]
    1f3c:	6801      	ldr	r1, [r0, #0]
    1f3e:	690b      	ldr	r3, [r1, #16]
    1f40:	a901      	add	r1, sp, #4
    1f42:	4798      	blx	r3
    1f44:	f1b0 3fff 	cmp.w	r0, #4294967295	@ 0xffffffff
    1f48:	dc02      	bgt.n	1f50 <thread_recv@@Base+0x3c>
    1f4a:	69e0      	ldr	r0, [r4, #28]
    1f4c:	2801      	cmp	r0, #1
    1f4e:	d14d      	bne.n	1fec <thread_recv@@Base+0xd8>
    1f50:	492e      	ldr	r1, [pc, #184]	@ (200c <thread_recv@@Base+0xf8>)
    1f52:	f10d 0609 	add.w	r6, sp, #9
    1f56:	9801      	ldr	r0, [sp, #4]
    1f58:	4d2d      	ldr	r5, [pc, #180]	@ (2010 <thread_recv@@Base+0xfc>)
    1f5a:	5060      	str	r0, [r4, r1]
    1f5c:	482f      	ldr	r0, [pc, #188]	@ (201c <thread_recv@@Base+0x108>)
    1f5e:	4478      	add	r0, pc
    1f60:	4681      	mov	r9, r0
    1f62:	482f      	ldr	r0, [pc, #188]	@ (2020 <thread_recv@@Base+0x10c>)
    1f64:	4478      	add	r0, pc
    1f66:	4682      	mov	sl, r0
    1f68:	e9d4 1006 	ldrd	r1, r0, [r4, #24]
    1f6c:	b319      	cbz	r1, 1fb6 <thread_recv@@Base+0xa2>
    1f6e:	2801      	cmp	r0, #1
    1f70:	d03d      	beq.n	1fee <thread_recv@@Base+0xda>
    1f72:	6860      	ldr	r0, [r4, #4]
    1f74:	4631      	mov	r1, r6
    1f76:	f240 4243 	movw	r2, #1091	@ 0x443
    1f7a:	f7ff eaac 	blx	14d4 <read@plt>
    1f7e:	4602      	mov	r2, r0
    1f80:	69e0      	ldr	r0, [r4, #28]
    1f82:	2801      	cmp	r0, #1
    1f84:	d033      	beq.n	1fee <thread_recv@@Base+0xda>
    1f86:	f89d 0009 	ldrb.w	r0, [sp, #9]
    1f8a:	2893      	cmp	r0, #147	@ 0x93
    1f8c:	bf04      	itt	eq
    1f8e:	f8bd 000b 	ldrheq.w	r0, [sp, #11]
    1f92:	4282      	cmpeq	r2, r0
    1f94:	d1e8      	bne.n	1f68 <thread_recv@@Base+0x54>
    1f96:	f89d 300a 	ldrb.w	r3, [sp, #10]
    1f9a:	1e58      	subs	r0, r3, #1
    1f9c:	2807      	cmp	r0, #7
    1f9e:	d815      	bhi.n	1fcc <thread_recv@@Base+0xb8>
    1fa0:	e8df f000 	tbb	[pc, r0]
    1fa4:	0f04      	lsrs	r4, r0, #28
    1fa6:	1a14      	subs	r4, r2, r0
    1fa8:	1414      	asrs	r4, r2, #16
    1faa:	1f14      	subs	r4, r2, #4
    1fac:	4620      	mov	r0, r4
    1fae:	4631      	mov	r1, r6
    1fb0:	f7ff ea96 	blx	14e0 <handle_mcu_msg_frag@plt>
    1fb4:	e7d8      	b.n	1f68 <thread_recv@@Base+0x54>
    1fb6:	2801      	cmp	r0, #1
    1fb8:	d019      	beq.n	1fee <thread_recv@@Base+0xda>
    1fba:	4628      	mov	r0, r5
    1fbc:	f7ff ea5a 	blx	1474 <usleep@plt>
    1fc0:	e7d2      	b.n	1f68 <thread_recv@@Base+0x54>
    1fc2:	4620      	mov	r0, r4
    1fc4:	4631      	mov	r1, r6
    1fc6:	f7ff ea92 	blx	14ec <handle_mcu_msg_ack@plt>
    1fca:	e7cd      	b.n	1f68 <thread_recv@@Base+0x54>
    1fcc:	2003      	movs	r0, #3
    1fce:	4649      	mov	r1, r9
    1fd0:	4652      	mov	r2, sl
    1fd2:	f7ff ea5c 	blx	148c <__android_log_print@plt>
    1fd6:	e7c7      	b.n	1f68 <thread_recv@@Base+0x54>
    1fd8:	4620      	mov	r0, r4
    1fda:	4631      	mov	r1, r6
    1fdc:	f7ff ea8c 	blx	14f8 <handle_mcu_msg_ctlmsg@plt>
    1fe0:	e7c2      	b.n	1f68 <thread_recv@@Base+0x54>
    1fe2:	4620      	mov	r0, r4
    1fe4:	4631      	mov	r1, r6
    1fe6:	f7ff ea8e 	blx	1504 <handle_mcu_msg_queryinfo_resp@plt>
    1fea:	e7bd      	b.n	1f68 <thread_recv@@Base+0x54>
    1fec:	e7fe      	b.n	1fec <thread_recv@@Base+0xd8>
    1fee:	f8d8 0000 	ldr.w	r0, [r8]
    1ff2:	f857 1c1c 	ldr.w	r1, [r7, #-28]
    1ff6:	1a40      	subs	r0, r0, r1
    1ff8:	bf01      	itttt	eq
    1ffa:	2001      	moveq	r0, #1
    1ffc:	f50d 6d8a 	addeq.w	sp, sp, #1104	@ 0x450
    2000:	e8bd 0700 	ldmiaeq.w	sp!, {r8, r9, sl}
    2004:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    2006:	f7ff e9d6 	blx	13b4 <__stack_chk_fail@plt>
    200a:	bf00      	nop
    200c:	0404      	lsls	r4, r0, #16
    200e:	0070      	lsls	r0, r6, #1
    2010:	86a0      	strh	r0, [r4, #52]	@ 0x34
    2012:	0001      	movs	r1, r0
    2014:	4faa      	ldr	r7, [pc, #680]	@ (22c0 <handle_mcu_msg_ctlmsg@@Base+0x68>)
    2016:	0000      	movs	r0, r0
    2018:	4f9e      	ldr	r7, [pc, #632]	@ (2294 <handle_mcu_msg_ctlmsg@@Base+0x3c>)
    201a:	0000      	movs	r0, r0
    201c:	2775      	movs	r7, #117	@ 0x75
    201e:	0000      	movs	r0, r0
    2020:	27d3      	movs	r7, #211	@ 0xd3
	...

00002024 <destroy_instance@@Base>:
    2024:	b5d0      	push	{r4, r6, r7, lr}
    2026:	af02      	add	r7, sp, #8
    2028:	4604      	mov	r4, r0
    202a:	2001      	movs	r0, #1
    202c:	61e0      	str	r0, [r4, #28]
    202e:	4805      	ldr	r0, [pc, #20]	@ (2044 <destroy_instance@@Base+0x20>)
    2030:	f7ff ea20 	blx	1474 <usleep@plt>
    2034:	6860      	ldr	r0, [r4, #4]
    2036:	f7ff ea6c 	blx	1510 <close@plt>
    203a:	4620      	mov	r0, r4
    203c:	e8bd 40d0 	ldmia.w	sp!, {r4, r6, r7, lr}
    2040:	f002 b85a 	b.w	40f8 <get_ip_port@@Base+0x16c0>
    2044:	4240      	negs	r0, r0
    2046:	000f      	movs	r7, r1

00002048 <mjpeg_ndk_startup@@Base>:
    2048:	2100      	movs	r1, #0
    204a:	66c1      	str	r1, [r0, #108]	@ 0x6c
    204c:	2101      	movs	r1, #1
    204e:	6181      	str	r1, [r0, #24]
    2050:	4770      	bx	lr

00002052 <mjpeg_ndk_start@@Base>:
    2052:	2101      	movs	r1, #1
    2054:	6181      	str	r1, [r0, #24]
    2056:	2000      	movs	r0, #0
    2058:	4770      	bx	lr

0000205a <mjpeg_ndk_stop@@Base>:
    205a:	2100      	movs	r1, #0
    205c:	6181      	str	r1, [r0, #24]
    205e:	2000      	movs	r0, #0
    2060:	4770      	bx	lr

00002062 <mjpeg_ndk_frame_callback_register@@Base>:
    2062:	2900      	cmp	r1, #0
    2064:	bf0e      	itee	eq
    2066:	f04f 30ff 	moveq.w	r0, #4294967295	@ 0xffffffff
    206a:	e9c0 1218 	strdne	r1, r2, [r0, #96]	@ 0x60
    206e:	2000      	movne	r0, #0
    2070:	4770      	bx	lr

00002072 <mjpeg_ndk_frame_callback_unregister@@Base>:
    2072:	2100      	movs	r1, #0
    2074:	e9c0 1118 	strd	r1, r1, [r0, #96]	@ 0x60
    2078:	2000      	movs	r0, #0
    207a:	4770      	bx	lr

0000207c <mjpeg_ndk_ctlmsg_cb_register@@Base>:
    207c:	2900      	cmp	r1, #0
    207e:	bf0e      	itee	eq
    2080:	f04f 30ff 	moveq.w	r0, #4294967295	@ 0xffffffff
    2084:	6681      	strne	r1, [r0, #104]	@ 0x68
    2086:	2000      	movne	r0, #0
    2088:	4770      	bx	lr

0000208a <mjpeg_ndk_ctlmsg_cb_unregister@@Base>:
    208a:	2100      	movs	r1, #0
    208c:	6681      	str	r1, [r0, #104]	@ 0x68
    208e:	2000      	movs	r0, #0
    2090:	4770      	bx	lr
	...

00002094 <mjpeg_ndk_command_send@@Base>:
    2094:	b5f0      	push	{r4, r5, r6, r7, lr}
    2096:	af03      	add	r7, sp, #12
    2098:	e92d 0ffe 	stmdb	sp!, {r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp}
    209c:	4605      	mov	r5, r0
    209e:	482e      	ldr	r0, [pc, #184]	@ (2158 <mjpeg_ndk_command_send@@Base+0xc4>)
    20a0:	f04f 36ff 	mov.w	r6, #4294967295	@ 0xffffffff
    20a4:	2900      	cmp	r1, #0
    20a6:	4478      	add	r0, pc
    20a8:	f8d0 9000 	ldr.w	r9, [r0]
    20ac:	f8d9 0000 	ldr.w	r0, [r9]
    20b0:	9006      	str	r0, [sp, #24]
    20b2:	d044      	beq.n	213e <mjpeg_ndk_command_send@@Base+0xaa>
    20b4:	4614      	mov	r4, r2
    20b6:	2a08      	cmp	r2, #8
    20b8:	dc41      	bgt.n	213e <mjpeg_ndk_command_send@@Base+0xaa>
    20ba:	2b00      	cmp	r3, #0
    20bc:	d03f      	beq.n	213e <mjpeg_ndk_command_send@@Base+0xaa>
    20be:	f8d7 a010 	ldr.w	sl, [r7, #16]
    20c2:	f1ba 0f00 	cmp.w	sl, #0
    20c6:	d03a      	beq.n	213e <mjpeg_ndk_command_send@@Base+0xaa>
    20c8:	69a8      	ldr	r0, [r5, #24]
    20ca:	b3b0      	cbz	r0, 213a <mjpeg_ndk_command_send@@Base+0xa6>
    20cc:	6f28      	ldr	r0, [r5, #112]	@ 0x70
    20ce:	b3a0      	cbz	r0, 213a <mjpeg_ndk_command_send@@Base+0xa6>
    20d0:	6a28      	ldr	r0, [r5, #32]
    20d2:	4622      	mov	r2, r4
    20d4:	4688      	mov	r8, r1
    20d6:	f100 0b01 	add.w	fp, r0, #1
    20da:	f104 000c 	add.w	r0, r4, #12
    20de:	f8c3 b000 	str.w	fp, [r3]
    20e2:	84e8      	strh	r0, [r5, #38]	@ 0x26
    20e4:	9001      	str	r0, [sp, #4]
    20e6:	f105 0030 	add.w	r0, r5, #48	@ 0x30
    20ea:	84ac      	strh	r4, [r5, #36]	@ 0x24
    20ec:	f8c5 b020 	str.w	fp, [r5, #32]
    20f0:	f7ff ea1a 	blx	1528 <__aeabi_memcpy@plt>
    20f4:	2600      	movs	r6, #0
    20f6:	68f8      	ldr	r0, [r7, #12]
    20f8:	656e      	str	r6, [r5, #84]	@ 0x54
    20fa:	4641      	mov	r1, r8
    20fc:	e9c5 0a16 	strd	r0, sl, [r5, #88]	@ 0x58
    2100:	4622      	mov	r2, r4
    2102:	68b8      	ldr	r0, [r7, #8]
    2104:	64e8      	str	r0, [r5, #76]	@ 0x4c
    2106:	9801      	ldr	r0, [sp, #4]
    2108:	f8cd b00c 	str.w	fp, [sp, #12]
    210c:	f8ad 000a 	strh.w	r0, [sp, #10]
    2110:	f240 40ef 	movw	r0, #1263	@ 0x4ef
    2114:	f8ad 0008 	strh.w	r0, [sp, #8]
    2118:	f105 0038 	add.w	r0, r5, #56	@ 0x38
    211c:	f8ad 6012 	strh.w	r6, [sp, #18]
    2120:	f8ad 4010 	strh.w	r4, [sp, #16]
    2124:	eddd 0b02 	vldr	d16, [sp, #8]
    2128:	f940 070f 	vst1.8	{d16}, [r0]
    212c:	9804      	ldr	r0, [sp, #16]
    212e:	6428      	str	r0, [r5, #64]	@ 0x40
    2130:	f105 0044 	add.w	r0, r5, #68	@ 0x44
    2134:	f7ff e9f8 	blx	1528 <__aeabi_memcpy@plt>
    2138:	e001      	b.n	213e <mjpeg_ndk_command_send@@Base+0xaa>
    213a:	f04f 36ff 	mov.w	r6, #4294967295	@ 0xffffffff
    213e:	f8d9 0000 	ldr.w	r0, [r9]
    2142:	9906      	ldr	r1, [sp, #24]
    2144:	1a40      	subs	r0, r0, r1
    2146:	bf01      	itttt	eq
    2148:	4630      	moveq	r0, r6
    214a:	b007      	addeq	sp, #28
    214c:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    2150:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    2152:	f7ff e930 	blx	13b4 <__stack_chk_fail@plt>
    2156:	bf00      	nop
    2158:	4e2a      	ldr	r6, [pc, #168]	@ (2204 <mjpeg_ndk_set_QPara@@Base+0x2c>)
	...

0000215c <mjpeg_ndk_queryinfo_cmd_send@@Base>:
    215c:	b5d0      	push	{r4, r6, r7, lr}
    215e:	af02      	add	r7, sp, #8
    2160:	b086      	sub	sp, #24
    2162:	4b11      	ldr	r3, [pc, #68]	@ (21a8 <mjpeg_ndk_queryinfo_cmd_send@@Base+0x4c>)
    2164:	447b      	add	r3, pc
    2166:	681c      	ldr	r4, [r3, #0]
    2168:	6823      	ldr	r3, [r4, #0]
    216a:	9305      	str	r3, [sp, #20]
    216c:	2300      	movs	r3, #0
    216e:	9104      	str	r1, [sp, #16]
    2170:	490b      	ldr	r1, [pc, #44]	@ (21a0 <mjpeg_ndk_queryinfo_cmd_send@@Base+0x44>)
    2172:	9103      	str	r1, [sp, #12]
    2174:	490b      	ldr	r1, [pc, #44]	@ (21a4 <mjpeg_ndk_queryinfo_cmd_send@@Base+0x48>)
    2176:	5042      	str	r2, [r0, r1]
    2178:	2110      	movs	r1, #16
    217a:	6842      	ldr	r2, [r0, #4]
    217c:	3008      	adds	r0, #8
    217e:	e9cd 0100 	strd	r0, r1, [sp]
    2182:	a903      	add	r1, sp, #12
    2184:	4610      	mov	r0, r2
    2186:	2208      	movs	r2, #8
    2188:	f7ff e98c 	blx	14a4 <sendto@plt>
    218c:	6820      	ldr	r0, [r4, #0]
    218e:	9905      	ldr	r1, [sp, #20]
    2190:	1a40      	subs	r0, r0, r1
    2192:	bf02      	ittt	eq
    2194:	2000      	moveq	r0, #0
    2196:	b006      	addeq	sp, #24
    2198:	bdd0      	popeq	{r4, r6, r7, pc}
    219a:	f7ff e90c 	blx	13b4 <__stack_chk_fail@plt>
    219e:	bf00      	nop
    21a0:	10ef      	asrs	r7, r5, #3
    21a2:	0008      	movs	r0, r1
    21a4:	03d8      	lsls	r0, r3, #15
    21a6:	0070      	lsls	r0, r6, #1
    21a8:	4d6c      	ldr	r5, [pc, #432]	@ (235c <handle_mcu_msg_frag@@Base+0x50>)
	...

000021ac <mjpeg_ndk_set_active_camera_index@@Base>:
    21ac:	b5b0      	push	{r4, r5, r7, lr}
    21ae:	af02      	add	r7, sp, #8
    21b0:	460c      	mov	r4, r1
    21b2:	4601      	mov	r1, r0
    21b4:	f04f 30ff 	mov.w	r0, #4294967295	@ 0xffffffff
    21b8:	b159      	cbz	r1, 21d2 <mjpeg_ndk_set_active_camera_index@@Base+0x26>
    21ba:	2c00      	cmp	r4, #0
    21bc:	d409      	bmi.n	21d2 <mjpeg_ndk_set_active_camera_index@@Base+0x26>
    21be:	4805      	ldr	r0, [pc, #20]	@ (21d4 <mjpeg_ndk_set_active_camera_index@@Base+0x28>)
    21c0:	180d      	adds	r5, r1, r0
    21c2:	4628      	mov	r0, r5
    21c4:	f7ff e974 	blx	14b0 <pthread_mutex_lock@plt>
    21c8:	4628      	mov	r0, r5
    21ca:	722c      	strb	r4, [r5, #8]
    21cc:	f7ff e97c 	blx	14c8 <pthread_mutex_unlock@plt>
    21d0:	2000      	movs	r0, #0
    21d2:	bdb0      	pop	{r4, r5, r7, pc}
    21d4:	03f8      	lsls	r0, r7, #15
    21d6:	0070      	lsls	r0, r6, #1

000021d8 <mjpeg_ndk_set_QPara@@Base>:
    21d8:	b5f0      	push	{r4, r5, r6, r7, lr}
    21da:	af03      	add	r7, sp, #12
    21dc:	e92d 0b00 	stmdb	sp!, {r8, r9, fp}
    21e0:	b380      	cbz	r0, 2244 <mjpeg_ndk_set_QPara@@Base+0x6c>
    21e2:	460c      	mov	r4, r1
    21e4:	3901      	subs	r1, #1
    21e6:	4615      	mov	r5, r2
    21e8:	b2ca      	uxtb	r2, r1
    21ea:	f04f 31ff 	mov.w	r1, #4294967295	@ 0xffffffff
    21ee:	42aa      	cmp	r2, r5
    21f0:	d22a      	bcs.n	2248 <mjpeg_ndk_set_QPara@@Base+0x70>
    21f2:	461e      	mov	r6, r3
    21f4:	b343      	cbz	r3, 2248 <mjpeg_ndk_set_QPara@@Base+0x70>
    21f6:	f8d7 9008 	ldr.w	r9, [r7, #8]
    21fa:	454e      	cmp	r6, r9
    21fc:	d224      	bcs.n	2248 <mjpeg_ndk_set_QPara@@Base+0x70>
    21fe:	4915      	ldr	r1, [pc, #84]	@ (2254 <mjpeg_ndk_set_QPara@@Base+0x7c>)
    2200:	2200      	movs	r2, #0
    2202:	4479      	add	r1, pc
    2204:	2a06      	cmp	r2, #6
    2206:	d01d      	beq.n	2244 <mjpeg_ndk_set_QPara@@Base+0x6c>
    2208:	5c8b      	ldrb	r3, [r1, r2]
    220a:	3201      	adds	r2, #1
    220c:	42a3      	cmp	r3, r4
    220e:	d1f9      	bne.n	2204 <mjpeg_ndk_set_QPara@@Base+0x2c>
    2210:	2200      	movs	r2, #0
    2212:	2a06      	cmp	r2, #6
    2214:	d016      	beq.n	2244 <mjpeg_ndk_set_QPara@@Base+0x6c>
    2216:	5c8b      	ldrb	r3, [r1, r2]
    2218:	3201      	adds	r2, #1
    221a:	42ab      	cmp	r3, r5
    221c:	d1f9      	bne.n	2212 <mjpeg_ndk_set_QPara@@Base+0x3a>
    221e:	490c      	ldr	r1, [pc, #48]	@ (2250 <mjpeg_ndk_set_QPara@@Base+0x78>)
    2220:	eb00 0801 	add.w	r8, r0, r1
    2224:	4640      	mov	r0, r8
    2226:	f7ff e944 	blx	14b0 <pthread_mutex_lock@plt>
    222a:	4640      	mov	r0, r8
    222c:	f888 9007 	strb.w	r9, [r8, #7]
    2230:	f888 6006 	strb.w	r6, [r8, #6]
    2234:	f888 5005 	strb.w	r5, [r8, #5]
    2238:	f888 4004 	strb.w	r4, [r8, #4]
    223c:	f7ff e944 	blx	14c8 <pthread_mutex_unlock@plt>
    2240:	2100      	movs	r1, #0
    2242:	e001      	b.n	2248 <mjpeg_ndk_set_QPara@@Base+0x70>
    2244:	f04f 31ff 	mov.w	r1, #4294967295	@ 0xffffffff
    2248:	4608      	mov	r0, r1
    224a:	e8bd 0b00 	ldmia.w	sp!, {r8, r9, fp}
    224e:	bdf0      	pop	{r4, r5, r6, r7, pc}
    2250:	03f8      	lsls	r0, r7, #15
    2252:	0070      	lsls	r0, r6, #1
    2254:	384e      	subs	r0, #78	@ 0x4e
	...

00002258 <handle_mcu_msg_ctlmsg@@Base>:
    2258:	b5f0      	push	{r4, r5, r6, r7, lr}
    225a:	af03      	add	r7, sp, #12
    225c:	f84d bd04 	str.w	fp, [sp, #-4]!
    2260:	b086      	sub	sp, #24
    2262:	4604      	mov	r4, r0
    2264:	481f      	ldr	r0, [pc, #124]	@ (22e4 <handle_mcu_msg_ctlmsg@@Base+0x8c>)
    2266:	4478      	add	r0, pc
    2268:	6806      	ldr	r6, [r0, #0]
    226a:	6830      	ldr	r0, [r6, #0]
    226c:	9005      	str	r0, [sp, #20]
    226e:	2000      	movs	r0, #0
    2270:	9003      	str	r0, [sp, #12]
    2272:	481a      	ldr	r0, [pc, #104]	@ (22dc <handle_mcu_msg_ctlmsg@@Base+0x84>)
    2274:	9002      	str	r0, [sp, #8]
    2276:	7808      	ldrb	r0, [r1, #0]
    2278:	2893      	cmp	r0, #147	@ 0x93
    227a:	d11e      	bne.n	22ba <handle_mcu_msg_ctlmsg@@Base+0x62>
    227c:	8848      	ldrh	r0, [r1, #2]
    227e:	460d      	mov	r5, r1
    2280:	4290      	cmp	r0, r2
    2282:	d11a      	bne.n	22ba <handle_mcu_msg_ctlmsg@@Base+0x62>
    2284:	686a      	ldr	r2, [r5, #4]
    2286:	66e2      	str	r2, [r4, #108]	@ 0x6c
    2288:	f8d4 c068 	ldr.w	ip, [r4, #104]	@ 0x68
    228c:	f1bc 0f00 	cmp.w	ip, #0
    2290:	d006      	beq.n	22a0 <handle_mcu_msg_ctlmsg@@Base+0x48>
    2292:	4813      	ldr	r0, [pc, #76]	@ (22e0 <handle_mcu_msg_ctlmsg@@Base+0x88>)
    2294:	8929      	ldrh	r1, [r5, #8]
    2296:	5823      	ldr	r3, [r4, r0]
    2298:	f105 000c 	add.w	r0, r5, #12
    229c:	47e0      	blx	ip
    229e:	686a      	ldr	r2, [r5, #4]
    22a0:	9203      	str	r2, [sp, #12]
    22a2:	2110      	movs	r1, #16
    22a4:	6860      	ldr	r0, [r4, #4]
    22a6:	f104 0208 	add.w	r2, r4, #8
    22aa:	e9cd 2100 	strd	r2, r1, [sp]
    22ae:	a902      	add	r1, sp, #8
    22b0:	2208      	movs	r2, #8
    22b2:	2300      	movs	r3, #0
    22b4:	f7ff e8f6 	blx	14a4 <sendto@plt>
    22b8:	e006      	b.n	22c8 <handle_mcu_msg_ctlmsg@@Base+0x70>
    22ba:	490b      	ldr	r1, [pc, #44]	@ (22e8 <handle_mcu_msg_ctlmsg@@Base+0x90>)
    22bc:	2003      	movs	r0, #3
    22be:	4a0b      	ldr	r2, [pc, #44]	@ (22ec <handle_mcu_msg_ctlmsg@@Base+0x94>)
    22c0:	4479      	add	r1, pc
    22c2:	447a      	add	r2, pc
    22c4:	f7ff e8e2 	blx	148c <__android_log_print@plt>
    22c8:	6830      	ldr	r0, [r6, #0]
    22ca:	9905      	ldr	r1, [sp, #20]
    22cc:	1a40      	subs	r0, r0, r1
    22ce:	bf02      	ittt	eq
    22d0:	b006      	addeq	sp, #24
    22d2:	f85d bb04 	ldreq.w	fp, [sp], #4
    22d6:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    22d8:	f7ff e86c 	blx	13b4 <__stack_chk_fail@plt>
    22dc:	08ef      	lsrs	r7, r5, #3
    22de:	0008      	movs	r0, r1
    22e0:	0404      	lsls	r4, r0, #16
    22e2:	0070      	lsls	r0, r6, #1
    22e4:	4c6a      	ldr	r4, [pc, #424]	@ (2490 <handle_mcu_msg_frag@@Base+0x184>)
    22e6:	0000      	movs	r0, r0
    22e8:	2413      	movs	r4, #19
    22ea:	0000      	movs	r0, r0
    22ec:	2491      	movs	r4, #145	@ 0x91
	...

000022f0 <handle_mcu_msg_ack@@Base>:
    22f0:	4602      	mov	r2, r0
    22f2:	6848      	ldr	r0, [r1, #4]
    22f4:	6a11      	ldr	r1, [r2, #32]
    22f6:	4288      	cmp	r0, r1
    22f8:	bf04      	itt	eq
    22fa:	6d51      	ldreq	r1, [r2, #84]	@ 0x54
    22fc:	2900      	cmpeq	r1, #0
    22fe:	d000      	beq.n	2302 <handle_mcu_msg_ack@@Base+0x12>
    2300:	4770      	bx	lr
    2302:	2101      	movs	r1, #1
    2304:	6551      	str	r1, [r2, #84]	@ 0x54
    2306:	e9d2 1216 	ldrd	r1, r2, [r2, #88]	@ 0x58
    230a:	4710      	bx	r2

0000230c <handle_mcu_msg_frag@@Base>:
    230c:	b5f0      	push	{r4, r5, r6, r7, lr}
    230e:	af03      	add	r7, sp, #12
    2310:	e92d 0f00 	stmdb	sp!, {r8, r9, sl, fp}
    2314:	b08d      	sub	sp, #52	@ 0x34
    2316:	e9d1 2908 	ldrd	r2, r9, [r1, #32]
    231a:	460c      	mov	r4, r1
    231c:	1c51      	adds	r1, r2, #1
    231e:	4549      	cmp	r1, r9
    2320:	f200 8176 	bhi.w	2610 <handle_mcu_msg_frag@@Base+0x304>
    2324:	49bd      	ldr	r1, [pc, #756]	@ (261c <handle_mcu_msg_frag@@Base+0x310>)
    2326:	9206      	str	r2, [sp, #24]
    2328:	eb00 0a01 	add.w	sl, r0, r1
    232c:	f104 0138 	add.w	r1, r4, #56	@ 0x38
    2330:	9105      	str	r1, [sp, #20]
    2332:	f894 1030 	ldrb.w	r1, [r4, #48]	@ 0x30
    2336:	9103      	str	r1, [sp, #12]
    2338:	8de1      	ldrh	r1, [r4, #46]	@ 0x2e
    233a:	9102      	str	r1, [sp, #8]
    233c:	8da1      	ldrh	r1, [r4, #44]	@ 0x2c
    233e:	9101      	str	r1, [sp, #4]
    2340:	6aa1      	ldr	r1, [r4, #40]	@ 0x28
    2342:	9104      	str	r1, [sp, #16]
    2344:	e9d4 b802 	ldrd	fp, r8, [r4, #8]
    2348:	e9d4 5606 	ldrd	r5, r6, [r4, #24]
    234c:	9009      	str	r0, [sp, #36]	@ 0x24
    234e:	307c      	adds	r0, #124	@ 0x7c
    2350:	9007      	str	r0, [sp, #28]
    2352:	f7ff e8ae 	blx	14b0 <pthread_mutex_lock@plt>
    2356:	4652      	mov	r2, sl
    2358:	e9c2 5600 	strd	r5, r6, [r2]
    235c:	2500      	movs	r5, #0
    235e:	e9da 0104 	ldrd	r0, r1, [sl, #16]
    2362:	ebb0 000b 	subs.w	r0, r0, fp
    2366:	eb71 0008 	sbcs.w	r0, r1, r8
    236a:	f04f 0100 	mov.w	r1, #0
    236e:	a80a      	add	r0, sp, #40	@ 0x28
    2370:	bf38      	it	cc
    2372:	e9c2 b804 	strdcc	fp, r8, [r2, #16]
    2376:	9208      	str	r2, [sp, #32]
    2378:	f7ff e846 	blx	1408 <gettimeofday@plt>
    237c:	9908      	ldr	r1, [sp, #32]
    237e:	f1ab 0001 	sub.w	r0, fp, #1
    2382:	f000 0003 	and.w	r0, r0, #3
    2386:	e9c1 b810 	strd	fp, r8, [r1, #64]	@ 0x40
    238a:	e9c1 0512 	strd	r0, r5, [r1, #72]	@ 0x48
    238e:	49a4      	ldr	r1, [pc, #656]	@ (2620 <handle_mcu_msg_frag@@Base+0x314>)
    2390:	9a09      	ldr	r2, [sp, #36]	@ 0x24
    2392:	fb00 2a01 	mla	sl, r0, r1, r2
    2396:	46d6      	mov	lr, sl
    2398:	f81e 1f80 	ldrb.w	r1, [lr, #128]!
    239c:	1ec8      	subs	r0, r1, #3
    239e:	2802      	cmp	r0, #2
    23a0:	d308      	bcc.n	23b4 <handle_mcu_msg_frag@@Base+0xa8>
    23a2:	b139      	cbz	r1, 23b4 <handle_mcu_msg_frag@@Base+0xa8>
    23a4:	f8dd 901c 	ldr.w	r9, [sp, #28]
    23a8:	2901      	cmp	r1, #1
    23aa:	f040 812e 	bne.w	260a <handle_mcu_msg_frag@@Base+0x2fe>
    23ae:	e9da c322 	ldrd	ip, r3, [sl, #136]	@ 0x88
    23b2:	e06a      	b.n	248a <handle_mcu_msg_frag@@Base+0x17e>
    23b4:	4650      	mov	r0, sl
    23b6:	f1bb 0304 	subs.w	r3, fp, #4
    23ba:	f850 cf88 	ldr.w	ip, [r0, #136]!
    23be:	f168 0600 	sbc.w	r6, r8, #0
    23c2:	ea8c 0503 	eor.w	r5, ip, r3
    23c6:	6843      	ldr	r3, [r0, #4]
    23c8:	405e      	eors	r6, r3
    23ca:	4335      	orrs	r5, r6
    23cc:	d008      	beq.n	23e0 <handle_mcu_msg_frag@@Base+0xd4>
    23ce:	2500      	movs	r5, #0
    23d0:	f1db 0604 	rsbs	r6, fp, #4
    23d4:	eb75 0508 	sbcs.w	r5, r5, r8
    23d8:	d352      	bcc.n	2480 <handle_mcu_msg_frag@@Base+0x174>
    23da:	ea5c 0503 	orrs.w	r5, ip, r3
    23de:	d14f      	bne.n	2480 <handle_mcu_msg_frag@@Base+0x174>
    23e0:	6f11      	ldr	r1, [r2, #112]	@ 0x70
    23e2:	b909      	cbnz	r1, 23e8 <handle_mcu_msg_frag@@Base+0xdc>
    23e4:	2101      	movs	r1, #1
    23e6:	6711      	str	r1, [r2, #112]	@ 0x70
    23e8:	e9dd 130a 	ldrd	r1, r3, [sp, #40]	@ 0x28
    23ec:	2601      	movs	r6, #1
    23ee:	e9c2 131d 	strd	r1, r3, [r2, #116]	@ 0x74
    23f2:	f10a 05a4 	add.w	r5, sl, #164	@ 0xa4
    23f6:	f8cd e024 	str.w	lr, [sp, #36]	@ 0x24
    23fa:	2180      	movs	r1, #128	@ 0x80
    23fc:	f88e 6000 	strb.w	r6, [lr]
    2400:	22ff      	movs	r2, #255	@ 0xff
    2402:	e9c0 b800 	strd	fp, r8, [r0]
    2406:	9803      	ldr	r0, [sp, #12]
    2408:	f88a 00a0 	strb.w	r0, [sl, #160]	@ 0xa0
    240c:	9802      	ldr	r0, [sp, #8]
    240e:	f8aa 009e 	strh.w	r0, [sl, #158]	@ 0x9e
    2412:	9801      	ldr	r0, [sp, #4]
    2414:	f8aa 009c 	strh.w	r0, [sl, #156]	@ 0x9c
    2418:	9804      	ldr	r0, [sp, #16]
    241a:	e9ca 9024 	strd	r9, r0, [sl, #144]	@ 0x90
    241e:	4628      	mov	r0, r5
    2420:	f7ff e888 	blx	1534 <__aeabi_memset@plt>
    2424:	f06f 0003 	mvn.w	r0, #3
    2428:	ea00 01d9 	and.w	r1, r0, r9, lsr #3
    242c:	4628      	mov	r0, r5
    242e:	f7ff e834 	blx	1498 <__aeabi_memclr@plt>
    2432:	ea4f 1059 	mov.w	r0, r9, lsr #5
    2436:	f009 011f 	and.w	r1, r9, #31
    243a:	eb05 0080 	add.w	r0, r5, r0, lsl #2
    243e:	2200      	movs	r2, #0
    2440:	4291      	cmp	r1, r2
    2442:	d007      	beq.n	2454 <handle_mcu_msg_frag@@Base+0x148>
    2444:	6805      	ldr	r5, [r0, #0]
    2446:	fa06 f302 	lsl.w	r3, r6, r2
    244a:	3201      	adds	r2, #1
    244c:	ea25 0303 	bic.w	r3, r5, r3
    2450:	6003      	str	r3, [r0, #0]
    2452:	e7f5      	b.n	2440 <handle_mcu_msg_frag@@Base+0x134>
    2454:	9906      	ldr	r1, [sp, #24]
    2456:	2301      	movs	r3, #1
    2458:	f001 021f 	and.w	r2, r1, #31
    245c:	0948      	lsrs	r0, r1, #5
    245e:	eb0a 0080 	add.w	r0, sl, r0, lsl #2
    2462:	fa03 f202 	lsl.w	r2, r3, r2
    2466:	f8d0 50a4 	ldr.w	r5, [r0, #164]	@ 0xa4
    246a:	432a      	orrs	r2, r5
    246c:	f8c0 20a4 	str.w	r2, [r0, #164]	@ 0xa4
    2470:	8863      	ldrh	r3, [r4, #2]
    2472:	9809      	ldr	r0, [sp, #36]	@ 0x24
    2474:	9a05      	ldr	r2, [sp, #20]
    2476:	f000 f8e3 	bl	2640 <handle_mcu_msg_frag@@Base+0x334>
    247a:	f8dd 901c 	ldr.w	r9, [sp, #28]
    247e:	e0c4      	b.n	260a <handle_mcu_msg_frag@@Base+0x2fe>
    2480:	f8dd 901c 	ldr.w	r9, [sp, #28]
    2484:	2901      	cmp	r1, #1
    2486:	f040 80c0 	bne.w	260a <handle_mcu_msg_frag@@Base+0x2fe>
    248a:	ea8c 000b 	eor.w	r0, ip, fp
    248e:	ea83 0108 	eor.w	r1, r3, r8
    2492:	4308      	orrs	r0, r1
    2494:	f040 80b9 	bne.w	260a <handle_mcu_msg_frag@@Base+0x2fe>
    2498:	485f      	ldr	r0, [pc, #380]	@ (2618 <handle_mcu_msg_frag@@Base+0x30c>)
    249a:	f04f 0801 	mov.w	r8, #1
    249e:	4410      	add	r0, r2
    24a0:	9004      	str	r0, [sp, #16]
    24a2:	e9dd 010a 	ldrd	r0, r1, [sp, #40]	@ 0x28
    24a6:	e9c2 011d 	strd	r0, r1, [r2, #116]	@ 0x74
    24aa:	9906      	ldr	r1, [sp, #24]
    24ac:	f001 021f 	and.w	r2, r1, #31
    24b0:	0948      	lsrs	r0, r1, #5
    24b2:	eb0a 0080 	add.w	r0, sl, r0, lsl #2
    24b6:	fa08 f202 	lsl.w	r2, r8, r2
    24ba:	f8d0 30a4 	ldr.w	r3, [r0, #164]	@ 0xa4
    24be:	431a      	orrs	r2, r3
    24c0:	f8c0 20a4 	str.w	r2, [r0, #164]	@ 0xa4
    24c4:	8863      	ldrh	r3, [r4, #2]
    24c6:	4670      	mov	r0, lr
    24c8:	9a05      	ldr	r2, [sp, #20]
    24ca:	4674      	mov	r4, lr
    24cc:	f000 f8b8 	bl	2640 <handle_mcu_msg_frag@@Base+0x334>
    24d0:	e9dd 5608 	ldrd	r5, r6, [sp, #32]
    24d4:	2101      	movs	r1, #1
    24d6:	f8da 0090 	ldr.w	r0, [sl, #144]	@ 0x90
    24da:	4281      	cmp	r1, r0
    24dc:	d20c      	bcs.n	24f8 <handle_mcu_msg_frag@@Base+0x1ec>
    24de:	094a      	lsrs	r2, r1, #5
    24e0:	f001 031f 	and.w	r3, r1, #31
    24e4:	eb0a 0282 	add.w	r2, sl, r2, lsl #2
    24e8:	3101      	adds	r1, #1
    24ea:	fa08 f303 	lsl.w	r3, r8, r3
    24ee:	f8d2 20a4 	ldr.w	r2, [r2, #164]	@ 0xa4
    24f2:	421a      	tst	r2, r3
    24f4:	d1f1      	bne.n	24da <handle_mcu_msg_frag@@Base+0x1ce>
    24f6:	e088      	b.n	260a <handle_mcu_msg_frag@@Base+0x2fe>
    24f8:	2002      	movs	r0, #2
    24fa:	7020      	strb	r0, [r4, #0]
    24fc:	2400      	movs	r4, #0
    24fe:	4849      	ldr	r0, [pc, #292]	@ (2624 <handle_mcu_msg_frag@@Base+0x318>)
    2500:	69ab      	ldr	r3, [r5, #24]
    2502:	4430      	add	r0, r6
    2504:	9006      	str	r0, [sp, #24]
    2506:	4848      	ldr	r0, [pc, #288]	@ (2628 <handle_mcu_msg_frag@@Base+0x31c>)
    2508:	9305      	str	r3, [sp, #20]
    250a:	4430      	add	r0, r6
    250c:	9003      	str	r0, [sp, #12]
    250e:	2c04      	cmp	r4, #4
    2510:	d07b      	beq.n	260a <handle_mcu_msg_frag@@Base+0x2fe>
    2512:	1918      	adds	r0, r3, r4
    2514:	17c1      	asrs	r1, r0, #31
    2516:	eb00 7191 	add.w	r1, r0, r1, lsr #30
    251a:	f021 0103 	bic.w	r1, r1, #3
    251e:	1a40      	subs	r0, r0, r1
    2520:	493f      	ldr	r1, [pc, #252]	@ (2620 <handle_mcu_msg_frag@@Base+0x314>)
    2522:	fb00 6801 	mla	r8, r0, r1, r6
    2526:	46c3      	mov	fp, r8
    2528:	f81b 0f80 	ldrb.w	r0, [fp, #128]!
    252c:	2802      	cmp	r0, #2
    252e:	d16a      	bne.n	2606 <handle_mcu_msg_frag@@Base+0x2fa>
    2530:	46c2      	mov	sl, r8
    2532:	e9d5 1202 	ldrd	r1, r2, [r5, #8]
    2536:	f85a 0f88 	ldr.w	r0, [sl, #136]!
    253a:	4048      	eors	r0, r1
    253c:	f8da 1004 	ldr.w	r1, [sl, #4]
    2540:	4051      	eors	r1, r2
    2542:	4308      	orrs	r0, r1
    2544:	d15f      	bne.n	2606 <handle_mcu_msg_frag@@Base+0x2fa>
    2546:	9e06      	ldr	r6, [sp, #24]
    2548:	4630      	mov	r0, r6
    254a:	f7fe efb2 	blx	14b0 <pthread_mutex_lock@plt>
    254e:	9d04      	ldr	r5, [sp, #16]
    2550:	f8d5 9008 	ldr.w	r9, [r5, #8]
    2554:	f1b9 0f02 	cmp.w	r9, #2
    2558:	d109      	bne.n	256e <handle_mcu_msg_frag@@Base+0x262>
    255a:	f04f 0901 	mov.w	r9, #1
    255e:	2103      	movs	r1, #3
    2560:	f8c5 9008 	str.w	r9, [r5, #8]
    2564:	6828      	ldr	r0, [r5, #0]
    2566:	3001      	adds	r0, #1
    2568:	f001 fdaa 	bl	40c0 <get_ip_port@@Base+0x1688>
    256c:	6029      	str	r1, [r5, #0]
    256e:	f109 0001 	add.w	r0, r9, #1
    2572:	60a8      	str	r0, [r5, #8]
    2574:	492d      	ldr	r1, [pc, #180]	@ (262c <handle_mcu_msg_frag@@Base+0x320>)
    2576:	6868      	ldr	r0, [r5, #4]
    2578:	9e03      	ldr	r6, [sp, #12]
    257a:	468c      	mov	ip, r1
    257c:	e9da 2300 	ldrd	r2, r3, [sl]
    2580:	4341      	muls	r1, r0
    2582:	fb00 600c 	mla	r0, r0, ip, r6
    2586:	5072      	str	r2, [r6, r1]
    2588:	6043      	str	r3, [r0, #4]
    258a:	f8d8 1098 	ldr.w	r1, [r8, #152]	@ 0x98
    258e:	6081      	str	r1, [r0, #8]
    2590:	f898 10a0 	ldrb.w	r1, [r8, #160]	@ 0xa0
    2594:	7301      	strb	r1, [r0, #12]
    2596:	4926      	ldr	r1, [pc, #152]	@ (2630 <handle_mcu_msg_frag@@Base+0x324>)
    2598:	4a26      	ldr	r2, [pc, #152]	@ (2634 <handle_mcu_msg_frag@@Base+0x328>)
    259a:	f858 1001 	ldr.w	r1, [r8, r1]
    259e:	5081      	str	r1, [r0, r2]
    25a0:	4925      	ldr	r1, [pc, #148]	@ (2638 <handle_mcu_msg_frag@@Base+0x32c>)
    25a2:	4441      	add	r1, r8
    25a4:	f961 070f 	vld1.8	{d16}, [r1]
    25a8:	4924      	ldr	r1, [pc, #144]	@ (263c <handle_mcu_msg_frag@@Base+0x330>)
    25aa:	4408      	add	r0, r1
    25ac:	f508 7192 	add.w	r1, r8, #292	@ 0x124
    25b0:	f940 070f 	vst1.8	{d16}, [r0]
    25b4:	6868      	ldr	r0, [r5, #4]
    25b6:	f8d8 2098 	ldr.w	r2, [r8, #152]	@ 0x98
    25ba:	fb00 600c 	mla	r0, r0, ip, r6
    25be:	300d      	adds	r0, #13
    25c0:	f7fe efb2 	blx	1528 <__aeabi_memcpy@plt>
    25c4:	6868      	ldr	r0, [r5, #4]
    25c6:	2103      	movs	r1, #3
    25c8:	3001      	adds	r0, #1
    25ca:	f001 fd79 	bl	40c0 <get_ip_port@@Base+0x1688>
    25ce:	2003      	movs	r0, #3
    25d0:	6069      	str	r1, [r5, #4]
    25d2:	f88b 0000 	strb.w	r0, [fp]
    25d6:	9806      	ldr	r0, [sp, #24]
    25d8:	f7fe ef76 	blx	14c8 <pthread_mutex_unlock@plt>
    25dc:	9d08      	ldr	r5, [sp, #32]
    25de:	e9d5 0102 	ldrd	r0, r1, [r5, #8]
    25e2:	69aa      	ldr	r2, [r5, #24]
    25e4:	3001      	adds	r0, #1
    25e6:	f141 0100 	adc.w	r1, r1, #0
    25ea:	e9c5 0102 	strd	r0, r1, [r5, #8]
    25ee:	1c50      	adds	r0, r2, #1
    25f0:	9e09      	ldr	r6, [sp, #36]	@ 0x24
    25f2:	17c1      	asrs	r1, r0, #31
    25f4:	f8dd 901c 	ldr.w	r9, [sp, #28]
    25f8:	9b05      	ldr	r3, [sp, #20]
    25fa:	eb00 7191 	add.w	r1, r0, r1, lsr #30
    25fe:	f021 0103 	bic.w	r1, r1, #3
    2602:	1a40      	subs	r0, r0, r1
    2604:	61a8      	str	r0, [r5, #24]
    2606:	3401      	adds	r4, #1
    2608:	e781      	b.n	250e <handle_mcu_msg_frag@@Base+0x202>
    260a:	4648      	mov	r0, r9
    260c:	f7fe ef5c 	blx	14c8 <pthread_mutex_unlock@plt>
    2610:	b00d      	add	sp, #52	@ 0x34
    2612:	e8bd 0f00 	ldmia.w	sp!, {r8, r9, sl, fp}
    2616:	bdf0      	pop	{r4, r5, r6, r7, pc}
    2618:	0340      	lsls	r0, r0, #13
    261a:	0040      	lsls	r0, r0, #1
    261c:	03a8      	lsls	r0, r5, #14
    261e:	0070      	lsls	r0, r6, #1
    2620:	00b0      	lsls	r0, r6, #2
    2622:	0010      	movs	r0, r2
    2624:	0398      	lsls	r0, r3, #14
    2626:	0070      	lsls	r0, r6, #1
    2628:	0350      	lsls	r0, r2, #13
    262a:	0040      	lsls	r0, r0, #1
    262c:	0018      	movs	r0, r3
    262e:	0010      	movs	r0, r2
    2630:	012b      	lsls	r3, r5, #4
    2632:	0010      	movs	r0, r2
    2634:	0014      	movs	r4, r2
    2636:	0010      	movs	r0, r2
    2638:	0124      	lsls	r4, r4, #4
    263a:	0010      	movs	r0, r2
    263c:	000d      	movs	r5, r1
    263e:	0010      	movs	r0, r2
    2640:	b5f0      	push	{r4, r5, r6, r7, lr}
    2642:	af03      	add	r7, sp, #12
    2644:	e92d 0bc0 	stmdb	sp!, {r6, r7, r8, r9, fp}
    2648:	4605      	mov	r5, r0
    264a:	6900      	ldr	r0, [r0, #16]
    264c:	4288      	cmp	r0, r1
    264e:	d96f      	bls.n	2730 <handle_mcu_msg_frag@@Base+0x424>
    2650:	460e      	mov	r6, r1
    2652:	493b      	ldr	r1, [pc, #236]	@ (2740 <handle_mcu_msg_frag@@Base+0x434>)
    2654:	4690      	mov	r8, r2
    2656:	4479      	add	r1, pc
    2658:	6809      	ldr	r1, [r1, #0]
    265a:	880c      	ldrh	r4, [r1, #0]
    265c:	b156      	cbz	r6, 2674 <handle_mcu_msg_frag@@Base+0x368>
    265e:	3801      	subs	r0, #1
    2660:	42b0      	cmp	r0, r6
    2662:	d150      	bne.n	2706 <handle_mcu_msg_frag@@Base+0x3fa>
    2664:	6969      	ldr	r1, [r5, #20]
    2666:	1928      	adds	r0, r5, r4
    2668:	4408      	add	r0, r1
    266a:	f64d 11ff 	movw	r1, #55807	@ 0xd9ff
    266e:	f8a0 10a4 	strh.w	r1, [r0, #164]	@ 0xa4
    2672:	e048      	b.n	2706 <handle_mcu_msg_frag@@Base+0x3fa>
    2674:	6968      	ldr	r0, [r5, #20]
    2676:	4699      	mov	r9, r3
    2678:	4420      	add	r0, r4
    267a:	3002      	adds	r0, #2
    267c:	61a8      	str	r0, [r5, #24]
    267e:	f895 0020 	ldrb.w	r0, [r5, #32]
    2682:	2805      	cmp	r0, #5
    2684:	d00c      	beq.n	26a0 <handle_mcu_msg_frag@@Base+0x394>
    2686:	2864      	cmp	r0, #100	@ 0x64
    2688:	d00d      	beq.n	26a6 <handle_mcu_msg_frag@@Base+0x39a>
    268a:	2819      	cmp	r0, #25
    268c:	d00e      	beq.n	26ac <handle_mcu_msg_frag@@Base+0x3a0>
    268e:	2832      	cmp	r0, #50	@ 0x32
    2690:	d00f      	beq.n	26b2 <handle_mcu_msg_frag@@Base+0x3a6>
    2692:	284b      	cmp	r0, #75	@ 0x4b
    2694:	d010      	beq.n	26b8 <handle_mcu_msg_frag@@Base+0x3ac>
    2696:	280a      	cmp	r0, #10
    2698:	d126      	bne.n	26e8 <handle_mcu_msg_frag@@Base+0x3dc>
    269a:	482b      	ldr	r0, [pc, #172]	@ (2748 <handle_mcu_msg_frag@@Base+0x43c>)
    269c:	4478      	add	r0, pc
    269e:	e00d      	b.n	26bc <handle_mcu_msg_frag@@Base+0x3b0>
    26a0:	4828      	ldr	r0, [pc, #160]	@ (2744 <handle_mcu_msg_frag@@Base+0x438>)
    26a2:	4478      	add	r0, pc
    26a4:	e00a      	b.n	26bc <handle_mcu_msg_frag@@Base+0x3b0>
    26a6:	482c      	ldr	r0, [pc, #176]	@ (2758 <handle_mcu_msg_frag@@Base+0x44c>)
    26a8:	4478      	add	r0, pc
    26aa:	e007      	b.n	26bc <handle_mcu_msg_frag@@Base+0x3b0>
    26ac:	4827      	ldr	r0, [pc, #156]	@ (274c <handle_mcu_msg_frag@@Base+0x440>)
    26ae:	4478      	add	r0, pc
    26b0:	e004      	b.n	26bc <handle_mcu_msg_frag@@Base+0x3b0>
    26b2:	4827      	ldr	r0, [pc, #156]	@ (2750 <handle_mcu_msg_frag@@Base+0x444>)
    26b4:	4478      	add	r0, pc
    26b6:	e001      	b.n	26bc <handle_mcu_msg_frag@@Base+0x3b0>
    26b8:	4826      	ldr	r0, [pc, #152]	@ (2754 <handle_mcu_msg_frag@@Base+0x448>)
    26ba:	4478      	add	r0, pc
    26bc:	6801      	ldr	r1, [r0, #0]
    26be:	f105 00a4 	add.w	r0, r5, #164	@ 0xa4
    26c2:	4622      	mov	r2, r4
    26c4:	f7fe ef30 	blx	1528 <__aeabi_memcpy@plt>
    26c8:	8be8      	ldrh	r0, [r5, #30]
    26ca:	ba00      	rev	r0, r0
    26cc:	0c00      	lsrs	r0, r0, #16
    26ce:	f827 0c1a 	strh.w	r0, [r7, #-26]
    26d2:	8ba9      	ldrh	r1, [r5, #28]
    26d4:	ba09      	rev	r1, r1
    26d6:	0c09      	lsrs	r1, r1, #16
    26d8:	f8ad 1004 	strh.w	r1, [sp, #4]
    26dc:	f8a5 0135 	strh.w	r0, [r5, #309]	@ 0x135
    26e0:	f8bd 0004 	ldrh.w	r0, [sp, #4]
    26e4:	f8a5 0137 	strh.w	r0, [r5, #311]	@ 0x137
    26e8:	f1a9 000b 	sub.w	r0, r9, #11
    26ec:	4a12      	ldr	r2, [pc, #72]	@ (2738 <handle_mcu_msg_frag@@Base+0x42c>)
    26ee:	fa18 f080 	uxtah	r0, r8, r0
    26f2:	f850 1c31 	ldr.w	r1, [r0, #-49]
    26f6:	3838      	subs	r0, #56	@ 0x38
    26f8:	50a9      	str	r1, [r5, r2]
    26fa:	4910      	ldr	r1, [pc, #64]	@ (273c <handle_mcu_msg_frag@@Base+0x430>)
    26fc:	f960 070f 	vld1.8	{d16}, [r0]
    2700:	4429      	add	r1, r5
    2702:	f941 070f 	vst1.8	{d16}, [r1]
    2706:	1928      	adds	r0, r5, r4
    2708:	6929      	ldr	r1, [r5, #16]
    270a:	eb00 2086 	add.w	r0, r0, r6, lsl #10
    270e:	3901      	subs	r1, #1
    2710:	30a4      	adds	r0, #164	@ 0xa4
    2712:	42b1      	cmp	r1, r6
    2714:	d107      	bne.n	2726 <handle_mcu_msg_frag@@Base+0x41a>
    2716:	696a      	ldr	r2, [r5, #20]
    2718:	f36f 229f 	bfc	r2, #10, #22
    271c:	2a00      	cmp	r2, #0
    271e:	bf08      	it	eq
    2720:	f44f 6280 	moveq.w	r2, #1024	@ 0x400
    2724:	e001      	b.n	272a <handle_mcu_msg_frag@@Base+0x41e>
    2726:	f44f 6280 	mov.w	r2, #1024	@ 0x400
    272a:	4641      	mov	r1, r8
    272c:	f7fe eefc 	blx	1528 <__aeabi_memcpy@plt>
    2730:	e8bd 0b0c 	ldmia.w	sp!, {r2, r3, r8, r9, fp}
    2734:	bdf0      	pop	{r4, r5, r6, r7, pc}
    2736:	bf00      	nop
    2738:	00ab      	lsls	r3, r5, #2
    273a:	0010      	movs	r0, r2
    273c:	00a4      	lsls	r4, r4, #2
    273e:	0010      	movs	r0, r2
    2740:	48a2      	ldr	r0, [pc, #648]	@ (29cc <time_interval_ms@@Base+0x2c>)
    2742:	0000      	movs	r0, r0
    2744:	485a      	ldr	r0, [pc, #360]	@ (28b0 <build_send_ack@@Base+0x154>)
    2746:	0000      	movs	r0, r0
    2748:	4864      	ldr	r0, [pc, #400]	@ (28dc <build_send_ack@@Base+0x180>)
    274a:	0000      	movs	r0, r0
    274c:	4856      	ldr	r0, [pc, #344]	@ (28a8 <build_send_ack@@Base+0x14c>)
    274e:	0000      	movs	r0, r0
    2750:	4854      	ldr	r0, [pc, #336]	@ (28a4 <build_send_ack@@Base+0x148>)
    2752:	0000      	movs	r0, r0
    2754:	4852      	ldr	r0, [pc, #328]	@ (28a0 <build_send_ack@@Base+0x144>)
    2756:	0000      	movs	r0, r0
    2758:	4868      	ldr	r0, [pc, #416]	@ (28fc <build_send_ack@@Base+0x1a0>)
	...

0000275c <build_send_ack@@Base>:
    275c:	b5f0      	push	{r4, r5, r6, r7, lr}
    275e:	af03      	add	r7, sp, #12
    2760:	e92d 0f00 	stmdb	sp!, {r8, r9, sl, fp}
    2764:	f5ad 7d47 	sub.w	sp, sp, #796	@ 0x31c
    2768:	4605      	mov	r5, r0
    276a:	488b      	ldr	r0, [pc, #556]	@ (2998 <build_send_ack@@Base+0x23c>)
    276c:	ac0a      	add	r4, sp, #40	@ 0x28
    276e:	468a      	mov	sl, r1
    2770:	4478      	add	r0, pc
    2772:	f240 21ee 	movw	r1, #750	@ 0x2ee
    2776:	6800      	ldr	r0, [r0, #0]
    2778:	9004      	str	r0, [sp, #16]
    277a:	6800      	ldr	r0, [r0, #0]
    277c:	90c6      	str	r0, [sp, #792]	@ 0x318
    277e:	4881      	ldr	r0, [pc, #516]	@ (2984 <build_send_ack@@Base+0x228>)
    2780:	5c2e      	ldrb	r6, [r5, r0]
    2782:	1ca0      	adds	r0, r4, #2
    2784:	f7fe ee88 	blx	1498 <__aeabi_memclr@plt>
    2788:	487f      	ldr	r0, [pc, #508]	@ (2988 <build_send_ack@@Base+0x22c>)
    278a:	2e00      	cmp	r6, #0
    278c:	900b      	str	r0, [sp, #44]	@ 0x2c
    278e:	f240 20ef 	movw	r0, #751	@ 0x2ef
    2792:	f8ad 0028 	strh.w	r0, [sp, #40]	@ 0x28
    2796:	f105 0b80 	add.w	fp, r5, #128	@ 0x80
    279a:	487c      	ldr	r0, [pc, #496]	@ (298c <build_send_ack@@Base+0x230>)
    279c:	f04f 0900 	mov.w	r9, #0
    27a0:	9409      	str	r4, [sp, #36]	@ 0x24
    27a2:	f04f 0c00 	mov.w	ip, #0
    27a6:	eb05 0e00 	add.w	lr, r5, r0
    27aa:	f04f 0010 	mov.w	r0, #16
    27ae:	9602      	str	r6, [sp, #8]
    27b0:	bf08      	it	eq
    27b2:	2020      	moveq	r0, #32
    27b4:	eb04 0800 	add.w	r8, r4, r0
    27b8:	9503      	str	r5, [sp, #12]
    27ba:	f8cd e014 	str.w	lr, [sp, #20]
    27be:	f1b9 0f04 	cmp.w	r9, #4
    27c2:	d06a      	beq.n	289a <build_send_ack@@Base+0x13e>
    27c4:	45ca      	cmp	sl, r9
    27c6:	d063      	beq.n	2890 <build_send_ack@@Base+0x134>
    27c8:	e9db 1002 	ldrd	r1, r0, [fp, #8]
    27cc:	e9de 4604 	ldrd	r4, r6, [lr, #16]
    27d0:	1a62      	subs	r2, r4, r1
    27d2:	eb66 0300 	sbc.w	r3, r6, r0
    27d6:	3a05      	subs	r2, #5
    27d8:	f173 0200 	sbcs.w	r2, r3, #0
    27dc:	d318      	bcc.n	2810 <build_send_ack@@Base+0xb4>
    27de:	f109 0201 	add.w	r2, r9, #1
    27e2:	2500      	movs	r5, #0
    27e4:	ea41 0300 	orr.w	r3, r1, r0
    27e8:	3104      	adds	r1, #4
    27ea:	f140 0000 	adc.w	r0, r0, #0
    27ee:	2b00      	cmp	r3, #0
    27f0:	bf04      	itt	eq
    27f2:	4628      	moveq	r0, r5
    27f4:	4611      	moveq	r1, r2
    27f6:	e9c8 1000 	strd	r1, r0, [r8]
    27fa:	2003      	movs	r0, #3
    27fc:	f10c 0c01 	add.w	ip, ip, #1
    2800:	f8c8 0008 	str.w	r0, [r8, #8]
    2804:	2010      	movs	r0, #16
    2806:	f8c8 000c 	str.w	r0, [r8, #12]
    280a:	f108 0810 	add.w	r8, r8, #16
    280e:	e03f      	b.n	2890 <build_send_ack@@Base+0x134>
    2810:	f89b 3000 	ldrb.w	r3, [fp]
    2814:	b933      	cbnz	r3, 2824 <build_send_ack@@Base+0xc8>
    2816:	f109 0201 	add.w	r2, r9, #1
    281a:	2500      	movs	r5, #0
    281c:	1b14      	subs	r4, r2, r4
    281e:	eb75 0406 	sbcs.w	r4, r5, r6
    2822:	d3df      	bcc.n	27e4 <build_send_ack@@Base+0x88>
    2824:	e9de 2400 	ldrd	r2, r4, [lr]
    2828:	1a52      	subs	r2, r2, r1
    282a:	eb74 0200 	sbcs.w	r2, r4, r0
    282e:	d22f      	bcs.n	2890 <build_send_ack@@Base+0x134>
    2830:	2b04      	cmp	r3, #4
    2832:	d807      	bhi.n	2844 <build_send_ack@@Base+0xe8>
    2834:	e8df f003 	tbb	[pc, r3]
    2838:	0a2c      	lsrs	r4, r5, #8
    283a:	0303      	lsls	r3, r0, #12
    283c:	000d      	movs	r5, r1
    283e:	4666      	mov	r6, ip
    2840:	2201      	movs	r2, #1
    2842:	e008      	b.n	2856 <build_send_ack@@Base+0xfa>
    2844:	4666      	mov	r6, ip
    2846:	f04f 32ff 	mov.w	r2, #4294967295	@ 0xffffffff
    284a:	e004      	b.n	2856 <build_send_ack@@Base+0xfa>
    284c:	4666      	mov	r6, ip
    284e:	2200      	movs	r2, #0
    2850:	e001      	b.n	2856 <build_send_ack@@Base+0xfa>
    2852:	4666      	mov	r6, ip
    2854:	2202      	movs	r2, #2
    2856:	f8db 3010 	ldr.w	r3, [fp, #16]
    285a:	2501      	movs	r5, #1
    285c:	06dc      	lsls	r4, r3, #27
    285e:	ea4f 1453 	mov.w	r4, r3, lsr #5
    2862:	bf18      	it	ne
    2864:	eb05 1453 	addne.w	r4, r5, r3, lsr #5
    2868:	2310      	movs	r3, #16
    286a:	eb03 0584 	add.w	r5, r3, r4, lsl #2
    286e:	e9c8 1000 	strd	r1, r0, [r8]
    2872:	f108 0010 	add.w	r0, r8, #16
    2876:	f10b 0124 	add.w	r1, fp, #36	@ 0x24
    287a:	e9c8 2502 	strd	r2, r5, [r8, #8]
    287e:	00a2      	lsls	r2, r4, #2
    2880:	f7fe ee52 	blx	1528 <__aeabi_memcpy@plt>
    2884:	46b4      	mov	ip, r6
    2886:	f8dd e014 	ldr.w	lr, [sp, #20]
    288a:	44a8      	add	r8, r5
    288c:	f106 0c01 	add.w	ip, r6, #1
    2890:	483f      	ldr	r0, [pc, #252]	@ (2990 <build_send_ack@@Base+0x234>)
    2892:	f109 0901 	add.w	r9, r9, #1
    2896:	4483      	add	fp, r0
    2898:	e791      	b.n	27be <build_send_ack@@Base+0x62>
    289a:	f11a 0002 	adds.w	r0, sl, #2
    289e:	d10d      	bne.n	28bc <build_send_ack@@Base+0x160>
    28a0:	9809      	ldr	r0, [sp, #36]	@ 0x24
    28a2:	2100      	movs	r1, #0
    28a4:	9c03      	ldr	r4, [sp, #12]
    28a6:	3020      	adds	r0, #32
    28a8:	4561      	cmp	r1, ip
    28aa:	da09      	bge.n	28c0 <build_send_ack@@Base+0x164>
    28ac:	6882      	ldr	r2, [r0, #8]
    28ae:	3a01      	subs	r2, #1
    28b0:	2a01      	cmp	r2, #1
    28b2:	d811      	bhi.n	28d8 <build_send_ack@@Base+0x17c>
    28b4:	68c2      	ldr	r2, [r0, #12]
    28b6:	3101      	adds	r1, #1
    28b8:	4410      	add	r0, r2
    28ba:	e7f5      	b.n	28a8 <build_send_ack@@Base+0x14c>
    28bc:	9c03      	ldr	r4, [sp, #12]
    28be:	e00b      	b.n	28d8 <build_send_ack@@Base+0x17c>
    28c0:	e9de 0102 	ldrd	r0, r1, [lr, #8]
    28c4:	2210      	movs	r2, #16
    28c6:	2303      	movs	r3, #3
    28c8:	f10c 0c01 	add.w	ip, ip, #1
    28cc:	e888 000b 	stmia.w	r8, {r0, r1, r3}
    28d0:	f8c8 200c 	str.w	r2, [r8, #12]
    28d4:	f108 0810 	add.w	r8, r8, #16
    28d8:	6a20      	ldr	r0, [r4, #32]
    28da:	b1a8      	cbz	r0, 2908 <build_send_ack@@Base+0x1ac>
    28dc:	a806      	add	r0, sp, #24
    28de:	2100      	movs	r1, #0
    28e0:	4665      	mov	r5, ip
    28e2:	f7fe ed92 	blx	1408 <gettimeofday@plt>
    28e6:	9b09      	ldr	r3, [sp, #36]	@ 0x24
    28e8:	f104 0130 	add.w	r1, r4, #48	@ 0x30
    28ec:	6a20      	ldr	r0, [r4, #32]
    28ee:	60d8      	str	r0, [r3, #12]
    28f0:	f103 0010 	add.w	r0, r3, #16
    28f4:	8ca2      	ldrh	r2, [r4, #36]	@ 0x24
    28f6:	f7fe ee18 	blx	1528 <__aeabi_memcpy@plt>
    28fa:	f8dd e014 	ldr.w	lr, [sp, #20]
    28fe:	46ac      	mov	ip, r5
    2900:	e9dd 0106 	ldrd	r0, r1, [sp, #24]
    2904:	e9c4 010a 	strd	r0, r1, [r4, #40]	@ 0x28
    2908:	9802      	ldr	r0, [sp, #8]
    290a:	b9d0      	cbnz	r0, 2942 <build_send_ack@@Base+0x1e6>
    290c:	4821      	ldr	r0, [pc, #132]	@ (2994 <build_send_ack@@Base+0x238>)
    290e:	46e1      	mov	r9, ip
    2910:	4675      	mov	r5, lr
    2912:	1826      	adds	r6, r4, r0
    2914:	4630      	mov	r0, r6
    2916:	f7fe edcc 	blx	14b0 <pthread_mutex_lock@plt>
    291a:	9909      	ldr	r1, [sp, #36]	@ 0x24
    291c:	f895 0054 	ldrb.w	r0, [r5, #84]	@ 0x54
    2920:	7608      	strb	r0, [r1, #24]
    2922:	f895 0055 	ldrb.w	r0, [r5, #85]	@ 0x55
    2926:	7648      	strb	r0, [r1, #25]
    2928:	f895 0056 	ldrb.w	r0, [r5, #86]	@ 0x56
    292c:	7688      	strb	r0, [r1, #26]
    292e:	f895 0057 	ldrb.w	r0, [r5, #87]	@ 0x57
    2932:	76c8      	strb	r0, [r1, #27]
    2934:	f895 0058 	ldrb.w	r0, [r5, #88]	@ 0x58
    2938:	7708      	strb	r0, [r1, #28]
    293a:	4630      	mov	r0, r6
    293c:	f7fe edc4 	blx	14c8 <pthread_mutex_unlock@plt>
    2940:	46cc      	mov	ip, r9
    2942:	9809      	ldr	r0, [sp, #36]	@ 0x24
    2944:	a909      	add	r1, sp, #36	@ 0x24
    2946:	eba8 0101 	sub.w	r1, r8, r1
    294a:	2210      	movs	r2, #16
    294c:	f104 0308 	add.w	r3, r4, #8
    2950:	f880 c008 	strb.w	ip, [r0, #8]
    2954:	8041      	strh	r1, [r0, #2]
    2956:	6860      	ldr	r0, [r4, #4]
    2958:	4664      	mov	r4, ip
    295a:	e9cd 3200 	strd	r3, r2, [sp]
    295e:	b28a      	uxth	r2, r1
    2960:	a90a      	add	r1, sp, #40	@ 0x28
    2962:	2300      	movs	r3, #0
    2964:	f7fe ed9e 	blx	14a4 <sendto@plt>
    2968:	9804      	ldr	r0, [sp, #16]
    296a:	6800      	ldr	r0, [r0, #0]
    296c:	99c6      	ldr	r1, [sp, #792]	@ 0x318
    296e:	1a40      	subs	r0, r0, r1
    2970:	bf01      	itttt	eq
    2972:	4620      	moveq	r0, r4
    2974:	f50d 7d47 	addeq.w	sp, sp, #796	@ 0x31c
    2978:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    297c:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    297e:	f7fe ed1a 	blx	13b4 <__stack_chk_fail@plt>
    2982:	bf00      	nop
    2984:	0401      	lsls	r1, r0, #16
    2986:	0070      	lsls	r0, r6, #1
    2988:	0202      	lsls	r2, r0, #8
    298a:	0100      	lsls	r0, r0, #4
    298c:	03a8      	lsls	r0, r5, #14
    298e:	0070      	lsls	r0, r6, #1
    2990:	00b0      	lsls	r0, r6, #2
    2992:	0010      	movs	r0, r2
    2994:	03f8      	lsls	r0, r7, #15
    2996:	0070      	lsls	r0, r6, #1
    2998:	4760      	bx	ip
    299a:	0000      	movs	r0, r0
    299c:	0000      	movs	r0, r0
	...

000029a0 <time_interval_ms@@Base>:
    29a0:	e9d0 2000 	ldrd	r2, r0, [r0]
    29a4:	e9d1 3100 	ldrd	r3, r1, [r1]
    29a8:	1a08      	subs	r0, r1, r0
    29aa:	eddf 1b0b 	vldr	d17, [pc, #44]	@ 29d8 <time_interval_ms@@Base+0x38>
    29ae:	f44f 717a 	mov.w	r1, #1000	@ 0x3e8
    29b2:	ee00 0a10 	vmov	s0, r0
    29b6:	1a98      	subs	r0, r3, r2
    29b8:	eef8 0bc0 	vcvt.f64.s32	d16, s0
    29bc:	4348      	muls	r0, r1
    29be:	eec0 0ba1 	vdiv.f64	d16, d16, d17
    29c2:	ee00 0a10 	vmov	s0, r0
    29c6:	eef8 1bc0 	vcvt.f64.s32	d17, s0
    29ca:	ee70 0ba1 	vadd.f64	d16, d16, d17
    29ce:	eebd 0be0 	vcvt.s32.f64	s0, d16
    29d2:	ee10 0a10 	vmov	r0, s0
    29d6:	4770      	bx	lr
    29d8:	0000      	movs	r0, r0
    29da:	0000      	movs	r0, r0
    29dc:	4000      	ands	r0, r0
    29de:	408f      	lsls	r7, r1

000029e0 <handle_mcu_msg_queryinfo_resp@@Base>:
    29e0:	4a02      	ldr	r2, [pc, #8]	@ (29ec <handle_mcu_msg_queryinfo_resp@@Base+0xc>)
    29e2:	5882      	ldr	r2, [r0, r2]
    29e4:	b10a      	cbz	r2, 29ea <handle_mcu_msg_queryinfo_resp@@Base+0xa>
    29e6:	4608      	mov	r0, r1
    29e8:	4710      	bx	r2
    29ea:	4770      	bx	lr
    29ec:	03d8      	lsls	r0, r3, #15
    29ee:	0070      	lsls	r0, r6, #1

000029f0 <get_ip_str@@Base>:
    29f0:	b5e0      	push	{r5, r6, r7, lr}
    29f2:	af02      	add	r7, sp, #8
    29f4:	b1d9      	cbz	r1, 2a2e <get_ip_str@@Base+0x3e>
    29f6:	4613      	mov	r3, r2
    29f8:	460a      	mov	r2, r1
    29fa:	8801      	ldrh	r1, [r0, #0]
    29fc:	290a      	cmp	r1, #10
    29fe:	d004      	beq.n	2a0a <get_ip_str@@Base+0x1a>
    2a00:	2902      	cmp	r1, #2
    2a02:	d10a      	bne.n	2a1a <get_ip_str@@Base+0x2a>
    2a04:	1d01      	adds	r1, r0, #4
    2a06:	2002      	movs	r0, #2
    2a08:	e002      	b.n	2a10 <get_ip_str@@Base+0x20>
    2a0a:	f100 0108 	add.w	r1, r0, #8
    2a0e:	200a      	movs	r0, #10
    2a10:	b002      	add	sp, #8
    2a12:	e8bd 4080 	ldmia.w	sp!, {r7, lr}
    2a16:	f001 bb77 	b.w	4108 <get_ip_port@@Base+0x16d0>
    2a1a:	200b      	movs	r0, #11
    2a1c:	9000      	str	r0, [sp, #0]
    2a1e:	4610      	mov	r0, r2
    2a20:	4904      	ldr	r1, [pc, #16]	@ (2a34 <get_ip_str@@Base+0x44>)
    2a22:	461a      	mov	r2, r3
    2a24:	f04f 33ff 	mov.w	r3, #4294967295	@ 0xffffffff
    2a28:	4479      	add	r1, pc
    2a2a:	f7fe ed90 	blx	154c <__strncpy_chk2@plt>
    2a2e:	2000      	movs	r0, #0
    2a30:	b002      	add	sp, #8
    2a32:	bd80      	pop	{r7, pc}
    2a34:	1d58      	adds	r0, r3, #5
	...

00002a38 <get_ip_port@@Base>:
    2a38:	8801      	ldrh	r1, [r0, #0]
    2a3a:	f041 0108 	orr.w	r1, r1, #8
    2a3e:	290a      	cmp	r1, #10
    2a40:	bf11      	iteee	ne
    2a42:	f04f 30ff 	movne.w	r0, #4294967295	@ 0xffffffff
    2a46:	8840      	ldrheq	r0, [r0, #2]
    2a48:	ba00      	reveq	r0, r0
    2a4a:	0c00      	lsreq	r0, r0, #16
    2a4c:	4770      	bx	lr
    2a4e:	0000      	movs	r0, r0
    2a50:	b5d0      	push	{r4, r6, r7, lr}
    2a52:	af02      	add	r7, sp, #8
    2a54:	6803      	ldr	r3, [r0, #0]
    2a56:	2b00      	cmp	r3, #0
    2a58:	d409      	bmi.n	2a6e <get_ip_port@@Base+0x36>
    2a5a:	2301      	movs	r3, #1
    2a5c:	600b      	str	r3, [r1, #0]
    2a5e:	2304      	movs	r3, #4
    2a60:	f850 1f04 	ldr.w	r1, [r0, #4]!
    2a64:	0e09      	lsrs	r1, r1, #24
    2a66:	eb03 0181 	add.w	r1, r3, r1, lsl #2
    2a6a:	6011      	str	r1, [r2, #0]
    2a6c:	bdd0      	pop	{r4, r6, r7, pc}
    2a6e:	f3c3 6403 	ubfx	r4, r3, #24, #4
    2a72:	b154      	cbz	r4, 2a8a <get_ip_port@@Base+0x52>
    2a74:	2c03      	cmp	r4, #3
    2a76:	bf18      	it	ne
    2a78:	2c01      	cmpne	r4, #1
    2a7a:	d10b      	bne.n	2a94 <get_ip_port@@Base+0x5c>
    2a7c:	f3c3 4307 	ubfx	r3, r3, #16, #8
    2a80:	2404      	movs	r4, #4
    2a82:	eb04 0483 	add.w	r4, r4, r3, lsl #2
    2a86:	2302      	movs	r3, #2
    2a88:	e001      	b.n	2a8e <get_ip_port@@Base+0x56>
    2a8a:	2301      	movs	r3, #1
    2a8c:	2404      	movs	r4, #4
    2a8e:	6014      	str	r4, [r2, #0]
    2a90:	600b      	str	r3, [r1, #0]
    2a92:	bdd0      	pop	{r4, r6, r7, pc}
    2a94:	2000      	movs	r0, #0
    2a96:	bdd0      	pop	{r4, r6, r7, pc}
    2a98:	b5f0      	push	{r4, r5, r6, r7, lr}
    2a9a:	af03      	add	r7, sp, #12
    2a9c:	e92d 0ff8 	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp}
    2aa0:	4604      	mov	r4, r0
    2aa2:	4896      	ldr	r0, [pc, #600]	@ (2cfc <get_ip_port@@Base+0x2c4>)
    2aa4:	4699      	mov	r9, r3
    2aa6:	4692      	mov	sl, r2
    2aa8:	4478      	add	r0, pc
    2aaa:	460e      	mov	r6, r1
    2aac:	f04f 0b00 	mov.w	fp, #0
    2ab0:	6800      	ldr	r0, [r0, #0]
    2ab2:	9001      	str	r0, [sp, #4]
    2ab4:	6800      	ldr	r0, [r0, #0]
    2ab6:	9004      	str	r0, [sp, #16]
    2ab8:	2000      	movs	r0, #0
    2aba:	9002      	str	r0, [sp, #8]
    2abc:	ea5f 70cb 	movs.w	r0, fp, lsl #31
    2ac0:	f040 8100 	bne.w	2cc4 <get_ip_port@@Base+0x28c>
    2ac4:	4655      	mov	r5, sl
    2ac6:	45ca      	cmp	sl, r9
    2ac8:	f080 80fc 	bcs.w	2cc4 <get_ip_port@@Base+0x28c>
    2acc:	f085 0003 	eor.w	r0, r5, #3
    2ad0:	f105 0a01 	add.w	sl, r5, #1
    2ad4:	f816 8000 	ldrb.w	r8, [r6, r0]
    2ad8:	ea5f 6008 	movs.w	r0, r8, lsl #24
    2adc:	d40d      	bmi.n	2afa <get_ip_port@@Base+0xc2>
    2ade:	aa03      	add	r2, sp, #12
    2ae0:	4620      	mov	r0, r4
    2ae2:	210d      	movs	r1, #13
    2ae4:	f000 fc18 	bl	3318 <get_ip_port@@Base+0x8e0>
    2ae8:	ea4f 0088 	mov.w	r0, r8, lsl #2
    2aec:	ea5f 6148 	movs.w	r1, r8, lsl #25
    2af0:	d42d      	bmi.n	2b4e <get_ip_port@@Base+0x116>
    2af2:	9903      	ldr	r1, [sp, #12]
    2af4:	4408      	add	r0, r1
    2af6:	1d02      	adds	r2, r0, #4
    2af8:	e02e      	b.n	2b58 <get_ip_port@@Base+0x120>
    2afa:	f008 00f0 	and.w	r0, r8, #240	@ 0xf0
    2afe:	3880      	subs	r0, #128	@ 0x80
    2b00:	0900      	lsrs	r0, r0, #4
    2b02:	2805      	cmp	r0, #5
    2b04:	f200 80dc 	bhi.w	2cc0 <get_ip_port@@Base+0x288>
    2b08:	e8df f000 	tbb	[pc, r0]
    2b0c:	2e03      	cmp	r6, #3
    2b0e:	5846      	ldr	r6, [r0, r1]
    2b10:	9c7b      	ldr	r4, [sp, #492]	@ 0x1ec
    2b12:	45ca      	cmp	sl, r9
    2b14:	f080 80d4 	bcs.w	2cc0 <get_ip_port@@Base+0x288>
    2b18:	f08a 0003 	eor.w	r0, sl, #3
    2b1c:	ea4f 3108 	mov.w	r1, r8, lsl #12
    2b20:	b289      	uxth	r1, r1
    2b22:	5c30      	ldrb	r0, [r6, r0]
    2b24:	ea41 1200 	orr.w	r2, r1, r0, lsl #4
    2b28:	2a00      	cmp	r2, #0
    2b2a:	f000 80c9 	beq.w	2cc0 <get_ip_port@@Base+0x288>
    2b2e:	4620      	mov	r0, r4
    2b30:	2100      	movs	r1, #0
    2b32:	2300      	movs	r3, #0
    2b34:	f04f 0b00 	mov.w	fp, #0
    2b38:	f000 f990 	bl	2e5c <get_ip_port@@Base+0x424>
    2b3c:	f008 0008 	and.w	r0, r8, #8
    2b40:	9902      	ldr	r1, [sp, #8]
    2b42:	f105 0a02 	add.w	sl, r5, #2
    2b46:	ea41 01d0 	orr.w	r1, r1, r0, lsr #3
    2b4a:	9102      	str	r1, [sp, #8]
    2b4c:	e7b6      	b.n	2abc <get_ip_port@@Base+0x84>
    2b4e:	9903      	ldr	r1, [sp, #12]
    2b50:	f000 00fc 	and.w	r0, r0, #252	@ 0xfc
    2b54:	1a08      	subs	r0, r1, r0
    2b56:	1f02      	subs	r2, r0, #4
    2b58:	4620      	mov	r0, r4
    2b5a:	210d      	movs	r1, #13
    2b5c:	9203      	str	r2, [sp, #12]
    2b5e:	f000 fbf5 	bl	334c <get_ip_port@@Base+0x914>
    2b62:	f04f 0b00 	mov.w	fp, #0
    2b66:	e7a9      	b.n	2abc <get_ip_port@@Base+0x84>
    2b68:	f048 0002 	orr.w	r0, r8, #2
    2b6c:	f000 000f 	and.w	r0, r0, #15
    2b70:	280f      	cmp	r0, #15
    2b72:	f000 80a5 	beq.w	2cc0 <get_ip_port@@Base+0x288>
    2b76:	a803      	add	r0, sp, #12
    2b78:	f008 020f 	and.w	r2, r8, #15
    2b7c:	9000      	str	r0, [sp, #0]
    2b7e:	4620      	mov	r0, r4
    2b80:	2100      	movs	r1, #0
    2b82:	2300      	movs	r3, #0
    2b84:	f04f 0b00 	mov.w	fp, #0
    2b88:	f000 f8ba 	bl	2d00 <get_ip_port@@Base+0x2c8>
    2b8c:	9a03      	ldr	r2, [sp, #12]
    2b8e:	4620      	mov	r0, r4
    2b90:	210d      	movs	r1, #13
    2b92:	f000 fbdb 	bl	334c <get_ip_port@@Base+0x914>
    2b96:	e791      	b.n	2abc <get_ip_port@@Base+0x84>
    2b98:	f008 0007 	and.w	r0, r8, #7
    2b9c:	2120      	movs	r1, #32
    2b9e:	2300      	movs	r3, #0
    2ba0:	f04f 0b00 	mov.w	fp, #0
    2ba4:	fa01 f000 	lsl.w	r0, r1, r0
    2ba8:	f008 0108 	and.w	r1, r8, #8
    2bac:	3810      	subs	r0, #16
    2bae:	ea40 22c1 	orr.w	r2, r0, r1, lsl #11
    2bb2:	4620      	mov	r0, r4
    2bb4:	2100      	movs	r1, #0
    2bb6:	f000 f951 	bl	2e5c <get_ip_port@@Base+0x424>
    2bba:	e77f      	b.n	2abc <get_ip_port@@Base+0x84>
    2bbc:	f1a8 01b0 	sub.w	r1, r8, #176	@ 0xb0
    2bc0:	2907      	cmp	r1, #7
    2bc2:	d84e      	bhi.n	2c62 <get_ip_port@@Base+0x22a>
    2bc4:	2009      	movs	r0, #9
    2bc6:	f04f 0b01 	mov.w	fp, #1
    2bca:	e8df f001 	tbb	[pc, r1]
    2bce:	0504      	lsls	r4, r0, #20
    2bd0:	6d4f      	ldr	r7, [r1, #84]	@ 0x54
    2bd2:	8989      	ldrh	r1, [r1, #12]
    2bd4:	8989      	ldrh	r1, [r1, #12]
    2bd6:	e771      	b.n	2abc <get_ip_port@@Base+0x84>
    2bd8:	45ca      	cmp	sl, r9
    2bda:	d271      	bcs.n	2cc0 <get_ip_port@@Base+0x288>
    2bdc:	f08a 0003 	eor.w	r0, sl, #3
    2be0:	5c32      	ldrb	r2, [r6, r0]
    2be2:	2009      	movs	r0, #9
    2be4:	2a00      	cmp	r2, #0
    2be6:	d07b      	beq.n	2ce0 <get_ip_port@@Base+0x2a8>
    2be8:	f012 01f0 	ands.w	r1, r2, #240	@ 0xf0
    2bec:	d178      	bne.n	2ce0 <get_ip_port@@Base+0x2a8>
    2bee:	4620      	mov	r0, r4
    2bf0:	2100      	movs	r1, #0
    2bf2:	2300      	movs	r3, #0
    2bf4:	f04f 0b00 	mov.w	fp, #0
    2bf8:	f000 f930 	bl	2e5c <get_ip_port@@Base+0x424>
    2bfc:	f105 0a02 	add.w	sl, r5, #2
    2c00:	e75c      	b.n	2abc <get_ip_port@@Base+0x84>
    2c02:	f008 00fe 	and.w	r0, r8, #254	@ 0xfe
    2c06:	28c8      	cmp	r0, #200	@ 0xc8
    2c08:	d15a      	bne.n	2cc0 <get_ip_port@@Base+0x288>
    2c0a:	f08a 0003 	eor.w	r0, sl, #3
    2c0e:	f1a8 02c8 	sub.w	r2, r8, #200	@ 0xc8
    2c12:	fab2 f282 	clz	r2, r2
    2c16:	5c31      	ldrb	r1, [r6, r0]
    2c18:	0952      	lsrs	r2, r2, #5
    2c1a:	0908      	lsrs	r0, r1, #4
    2c1c:	f001 010f 	and.w	r1, r1, #15
    2c20:	ea40 1002 	orr.w	r0, r0, r2, lsl #4
    2c24:	1842      	adds	r2, r0, r1
    2c26:	2a1f      	cmp	r2, #31
    2c28:	d84a      	bhi.n	2cc0 <get_ip_port@@Base+0x288>
    2c2a:	ea41 4000 	orr.w	r0, r1, r0, lsl #16
    2c2e:	2101      	movs	r1, #1
    2c30:	1c42      	adds	r2, r0, #1
    2c32:	4620      	mov	r0, r4
    2c34:	2305      	movs	r3, #5
    2c36:	f000 f911 	bl	2e5c <get_ip_port@@Base+0x424>
    2c3a:	f105 0a02 	add.w	sl, r5, #2
    2c3e:	f04f 0b00 	mov.w	fp, #0
    2c42:	e73b      	b.n	2abc <get_ip_port@@Base+0x84>
    2c44:	ea5f 7008 	movs.w	r0, r8, lsl #28
    2c48:	d43a      	bmi.n	2cc0 <get_ip_port@@Base+0x288>
    2c4a:	492b      	ldr	r1, [pc, #172]	@ (2cf8 <get_ip_port@@Base+0x2c0>)
    2c4c:	f008 0007 	and.w	r0, r8, #7
    2c50:	2305      	movs	r3, #5
    2c52:	1842      	adds	r2, r0, r1
    2c54:	4620      	mov	r0, r4
    2c56:	2101      	movs	r1, #1
    2c58:	f000 f900 	bl	2e5c <get_ip_port@@Base+0x424>
    2c5c:	f04f 0b00 	mov.w	fp, #0
    2c60:	e72c      	b.n	2abc <get_ip_port@@Base+0x84>
    2c62:	4925      	ldr	r1, [pc, #148]	@ (2cf8 <get_ip_port@@Base+0x2c0>)
    2c64:	f008 0007 	and.w	r0, r8, #7
    2c68:	2301      	movs	r3, #1
    2c6a:	e7f2      	b.n	2c52 <get_ip_port@@Base+0x21a>
    2c6c:	2500      	movs	r5, #0
    2c6e:	2000      	movs	r0, #0
    2c70:	45d1      	cmp	r9, sl
    2c72:	d025      	beq.n	2cc0 <get_ip_port@@Base+0x288>
    2c74:	f08a 0103 	eor.w	r1, sl, #3
    2c78:	f10a 0a01 	add.w	sl, sl, #1
    2c7c:	5c71      	ldrb	r1, [r6, r1]
    2c7e:	f001 027f 	and.w	r2, r1, #127	@ 0x7f
    2c82:	0609      	lsls	r1, r1, #24
    2c84:	fa02 f200 	lsl.w	r2, r2, r0
    2c88:	ea45 0502 	orr.w	r5, r5, r2
    2c8c:	f100 0007 	add.w	r0, r0, #7
    2c90:	d4ee      	bmi.n	2c70 <get_ip_port@@Base+0x238>
    2c92:	aa03      	add	r2, sp, #12
    2c94:	4620      	mov	r0, r4
    2c96:	210d      	movs	r1, #13
    2c98:	f000 fb3e 	bl	3318 <get_ip_port@@Base+0x8e0>
    2c9c:	9803      	ldr	r0, [sp, #12]
    2c9e:	eb00 0085 	add.w	r0, r0, r5, lsl #2
    2ca2:	f500 7201 	add.w	r2, r0, #516	@ 0x204
    2ca6:	e757      	b.n	2b58 <get_ip_port@@Base+0x120>
    2ca8:	f08a 0003 	eor.w	r0, sl, #3
    2cac:	2101      	movs	r1, #1
    2cae:	2301      	movs	r3, #1
    2cb0:	5c30      	ldrb	r0, [r6, r0]
    2cb2:	ea40 3000 	orr.w	r0, r0, r0, lsl #12
    2cb6:	f000 100f 	and.w	r0, r0, #983055	@ 0xf000f
    2cba:	1c42      	adds	r2, r0, #1
    2cbc:	4620      	mov	r0, r4
    2cbe:	e7ba      	b.n	2c36 <get_ip_port@@Base+0x1fe>
    2cc0:	2009      	movs	r0, #9
    2cc2:	e00d      	b.n	2ce0 <get_ip_port@@Base+0x2a8>
    2cc4:	9802      	ldr	r0, [sp, #8]
    2cc6:	07c0      	lsls	r0, r0, #31
    2cc8:	d109      	bne.n	2cde <get_ip_port@@Base+0x2a6>
    2cca:	aa03      	add	r2, sp, #12
    2ccc:	4620      	mov	r0, r4
    2cce:	210e      	movs	r1, #14
    2cd0:	f000 fb22 	bl	3318 <get_ip_port@@Base+0x8e0>
    2cd4:	9a03      	ldr	r2, [sp, #12]
    2cd6:	4620      	mov	r0, r4
    2cd8:	210f      	movs	r1, #15
    2cda:	f000 fb37 	bl	334c <get_ip_port@@Base+0x914>
    2cde:	2008      	movs	r0, #8
    2ce0:	9901      	ldr	r1, [sp, #4]
    2ce2:	6809      	ldr	r1, [r1, #0]
    2ce4:	9a04      	ldr	r2, [sp, #16]
    2ce6:	1a89      	subs	r1, r1, r2
    2ce8:	bf02      	ittt	eq
    2cea:	b005      	addeq	sp, #20
    2cec:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    2cf0:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    2cf2:	f7fe eb60 	blx	13b4 <__stack_chk_fail@plt>
    2cf6:	bf00      	nop
    2cf8:	0001      	movs	r1, r0
    2cfa:	0008      	movs	r0, r1
    2cfc:	4428      	add	r0, r5
    2cfe:	0000      	movs	r0, r0
    2d00:	b5f0      	push	{r4, r5, r6, r7, lr}
    2d02:	af03      	add	r7, sp, #12
    2d04:	f84d bd04 	str.w	fp, [sp, #-4]!
    2d08:	b082      	sub	sp, #8
    2d0a:	68bc      	ldr	r4, [r7, #8]
    2d0c:	4615      	mov	r5, r2
    2d0e:	4606      	mov	r6, r0
    2d10:	2901      	cmp	r1, #1
    2d12:	d00a      	beq.n	2d2a <get_ip_port@@Base+0x2f2>
    2d14:	bb39      	cbnz	r1, 2d66 <get_ip_port@@Base+0x32e>
    2d16:	2002      	movs	r0, #2
    2d18:	2d0f      	cmp	r5, #15
    2d1a:	d820      	bhi.n	2d5e <get_ip_port@@Base+0x326>
    2d1c:	b9fb      	cbnz	r3, 2d5e <get_ip_port@@Base+0x326>
    2d1e:	4630      	mov	r0, r6
    2d20:	4629      	mov	r1, r5
    2d22:	4622      	mov	r2, r4
    2d24:	f000 faf8 	bl	3318 <get_ip_port@@Base+0x8e0>
    2d28:	e015      	b.n	2d56 <get_ip_port@@Base+0x31e>
    2d2a:	f043 0004 	orr.w	r0, r3, #4
    2d2e:	2805      	cmp	r0, #5
    2d30:	d109      	bne.n	2d46 <get_ip_port@@Base+0x30e>
    2d32:	2b01      	cmp	r3, #1
    2d34:	d105      	bne.n	2d42 <get_ip_port@@Base+0x30a>
    2d36:	2d0f      	cmp	r5, #15
    2d38:	d805      	bhi.n	2d46 <get_ip_port@@Base+0x30e>
    2d3a:	4630      	mov	r0, r6
    2d3c:	f000 fb9f 	bl	347e <get_ip_port@@Base+0xa46>
    2d40:	e003      	b.n	2d4a <get_ip_port@@Base+0x312>
    2d42:	2d1f      	cmp	r5, #31
    2d44:	d901      	bls.n	2d4a <get_ip_port@@Base+0x312>
    2d46:	2002      	movs	r0, #2
    2d48:	e009      	b.n	2d5e <get_ip_port@@Base+0x326>
    2d4a:	f505 7180 	add.w	r1, r5, #256	@ 0x100
    2d4e:	4630      	mov	r0, r6
    2d50:	4622      	mov	r2, r4
    2d52:	f000 fb1f 	bl	3394 <get_ip_port@@Base+0x95c>
    2d56:	2800      	cmp	r0, #0
    2d58:	bf18      	it	ne
    2d5a:	2001      	movne	r0, #1
    2d5c:	0040      	lsls	r0, r0, #1
    2d5e:	b002      	add	sp, #8
    2d60:	f85d bb04 	ldr.w	fp, [sp], #4
    2d64:	bdf0      	pop	{r4, r5, r6, r7, pc}
    2d66:	480c      	ldr	r0, [pc, #48]	@ (2d98 <get_ip_port@@Base+0x360>)
    2d68:	f240 315e 	movw	r1, #862	@ 0x35e
    2d6c:	4478      	add	r0, pc
    2d6e:	e9cd 1000 	strd	r1, r0, [sp]
    2d72:	480a      	ldr	r0, [pc, #40]	@ (2d9c <get_ip_port@@Base+0x364>)
    2d74:	490a      	ldr	r1, [pc, #40]	@ (2da0 <get_ip_port@@Base+0x368>)
    2d76:	4478      	add	r0, pc
    2d78:	4a0a      	ldr	r2, [pc, #40]	@ (2da4 <get_ip_port@@Base+0x36c>)
    2d7a:	4b0b      	ldr	r3, [pc, #44]	@ (2da8 <get_ip_port@@Base+0x370>)
    2d7c:	4479      	add	r1, pc
    2d7e:	6800      	ldr	r0, [r0, #0]
    2d80:	447a      	add	r2, pc
    2d82:	447b      	add	r3, pc
    2d84:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    2d88:	4620      	mov	r0, r4
    2d8a:	f7fe ebe6 	blx	1558 <fprintf@plt>
    2d8e:	4620      	mov	r0, r4
    2d90:	f7fe ebe8 	blx	1564 <fflush@plt>
    2d94:	f7fe ebec 	blx	1570 <abort@plt>
    2d98:	1aef      	subs	r7, r5, r3
    2d9a:	0000      	movs	r0, r0
    2d9c:	419e      	sbcs	r6, r3
    2d9e:	0000      	movs	r0, r0
    2da0:	1a0f      	subs	r7, r1, r0
    2da2:	0000      	movs	r0, r0
    2da4:	1b77      	subs	r7, r6, r5
    2da6:	0000      	movs	r0, r0
    2da8:	1a32      	subs	r2, r6, r0
    2daa:	0000      	movs	r0, r0
    2dac:	b5f0      	push	{r4, r5, r6, r7, lr}
    2dae:	af03      	add	r7, sp, #12
    2db0:	f84d bd04 	str.w	fp, [sp, #-4]!
    2db4:	b082      	sub	sp, #8
    2db6:	68be      	ldr	r6, [r7, #8]
    2db8:	4614      	mov	r4, r2
    2dba:	4605      	mov	r5, r0
    2dbc:	2901      	cmp	r1, #1
    2dbe:	d00a      	beq.n	2dd6 <get_ip_port@@Base+0x39e>
    2dc0:	bb41      	cbnz	r1, 2e14 <get_ip_port@@Base+0x3dc>
    2dc2:	2002      	movs	r0, #2
    2dc4:	2c0f      	cmp	r4, #15
    2dc6:	d821      	bhi.n	2e0c <get_ip_port@@Base+0x3d4>
    2dc8:	bb03      	cbnz	r3, 2e0c <get_ip_port@@Base+0x3d4>
    2dca:	6832      	ldr	r2, [r6, #0]
    2dcc:	4628      	mov	r0, r5
    2dce:	4621      	mov	r1, r4
    2dd0:	f000 fabc 	bl	334c <get_ip_port@@Base+0x914>
    2dd4:	e016      	b.n	2e04 <get_ip_port@@Base+0x3cc>
    2dd6:	f043 0004 	orr.w	r0, r3, #4
    2dda:	2805      	cmp	r0, #5
    2ddc:	d109      	bne.n	2df2 <get_ip_port@@Base+0x3ba>
    2dde:	2b01      	cmp	r3, #1
    2de0:	d105      	bne.n	2dee <get_ip_port@@Base+0x3b6>
    2de2:	2c0f      	cmp	r4, #15
    2de4:	d805      	bhi.n	2df2 <get_ip_port@@Base+0x3ba>
    2de6:	4628      	mov	r0, r5
    2de8:	f000 fb49 	bl	347e <get_ip_port@@Base+0xa46>
    2dec:	e003      	b.n	2df6 <get_ip_port@@Base+0x3be>
    2dee:	2c1f      	cmp	r4, #31
    2df0:	d901      	bls.n	2df6 <get_ip_port@@Base+0x3be>
    2df2:	2002      	movs	r0, #2
    2df4:	e00a      	b.n	2e0c <get_ip_port@@Base+0x3d4>
    2df6:	e9d6 2300 	ldrd	r2, r3, [r6]
    2dfa:	f504 7180 	add.w	r1, r4, #256	@ 0x100
    2dfe:	4628      	mov	r0, r5
    2e00:	f000 fae4 	bl	33cc <get_ip_port@@Base+0x994>
    2e04:	2800      	cmp	r0, #0
    2e06:	bf18      	it	ne
    2e08:	2001      	movne	r0, #1
    2e0a:	0040      	lsls	r0, r0, #1
    2e0c:	b002      	add	sp, #8
    2e0e:	f85d bb04 	ldr.w	fp, [sp], #4
    2e12:	bdf0      	pop	{r4, r5, r6, r7, pc}
    2e14:	480c      	ldr	r0, [pc, #48]	@ (2e48 <get_ip_port@@Base+0x410>)
    2e16:	f44f 714a 	mov.w	r1, #808	@ 0x328
    2e1a:	4478      	add	r0, pc
    2e1c:	e9cd 1000 	strd	r1, r0, [sp]
    2e20:	480a      	ldr	r0, [pc, #40]	@ (2e4c <get_ip_port@@Base+0x414>)
    2e22:	490b      	ldr	r1, [pc, #44]	@ (2e50 <get_ip_port@@Base+0x418>)
    2e24:	4478      	add	r0, pc
    2e26:	4a0b      	ldr	r2, [pc, #44]	@ (2e54 <get_ip_port@@Base+0x41c>)
    2e28:	4b0b      	ldr	r3, [pc, #44]	@ (2e58 <get_ip_port@@Base+0x420>)
    2e2a:	4479      	add	r1, pc
    2e2c:	6800      	ldr	r0, [r0, #0]
    2e2e:	447a      	add	r2, pc
    2e30:	447b      	add	r3, pc
    2e32:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    2e36:	4620      	mov	r0, r4
    2e38:	f7fe eb8e 	blx	1558 <fprintf@plt>
    2e3c:	4620      	mov	r0, r4
    2e3e:	f7fe eb92 	blx	1564 <fflush@plt>
    2e42:	f7fe eb96 	blx	1570 <abort@plt>
    2e46:	bf00      	nop
    2e48:	1a41      	subs	r1, r0, r1
    2e4a:	0000      	movs	r0, r0
    2e4c:	40f0      	lsrs	r0, r6
    2e4e:	0000      	movs	r0, r0
    2e50:	1961      	adds	r1, r4, r5
    2e52:	0000      	movs	r0, r0
    2e54:	1a1d      	subs	r5, r3, r0
    2e56:	0000      	movs	r0, r0
    2e58:	1984      	adds	r4, r0, r6
    2e5a:	0000      	movs	r0, r0
    2e5c:	b5f0      	push	{r4, r5, r6, r7, lr}
    2e5e:	af03      	add	r7, sp, #12
    2e60:	e92d 0ffe 	stmdb	sp!, {r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp}
    2e64:	4682      	mov	sl, r0
    2e66:	484b      	ldr	r0, [pc, #300]	@ (2f94 <get_ip_port@@Base+0x55c>)
    2e68:	461e      	mov	r6, r3
    2e6a:	4690      	mov	r8, r2
    2e6c:	4478      	add	r0, pc
    2e6e:	2901      	cmp	r1, #1
    2e70:	f8d0 9000 	ldr.w	r9, [r0]
    2e74:	f8d9 0000 	ldr.w	r0, [r9]
    2e78:	9006      	str	r0, [sp, #24]
    2e7a:	d02b      	beq.n	2ed4 <get_ip_port@@Base+0x49c>
    2e7c:	2900      	cmp	r1, #0
    2e7e:	d170      	bne.n	2f62 <get_ip_port@@Base+0x52a>
    2e80:	2e00      	cmp	r6, #0
    2e82:	d14c      	bne.n	2f1e <get_ip_port@@Base+0x4e6>
    2e84:	aa02      	add	r2, sp, #8
    2e86:	4650      	mov	r0, sl
    2e88:	210d      	movs	r1, #13
    2e8a:	f000 fa45 	bl	3318 <get_ip_port@@Base+0x8e0>
    2e8e:	2800      	cmp	r0, #0
    2e90:	d145      	bne.n	2f1e <get_ip_port@@Base+0x4e6>
    2e92:	ac05      	add	r4, sp, #20
    2e94:	2600      	movs	r6, #0
    2e96:	f04f 0b01 	mov.w	fp, #1
    2e9a:	2500      	movs	r5, #0
    2e9c:	2e10      	cmp	r6, #16
    2e9e:	d050      	beq.n	2f42 <get_ip_port@@Base+0x50a>
    2ea0:	fa0b f006 	lsl.w	r0, fp, r6
    2ea4:	ea10 0f08 	tst.w	r0, r8
    2ea8:	d012      	beq.n	2ed0 <get_ip_port@@Base+0x498>
    2eaa:	9802      	ldr	r0, [sp, #8]
    2eac:	4632      	mov	r2, r6
    2eae:	2300      	movs	r3, #0
    2eb0:	1d01      	adds	r1, r0, #4
    2eb2:	9102      	str	r1, [sp, #8]
    2eb4:	6800      	ldr	r0, [r0, #0]
    2eb6:	2100      	movs	r1, #0
    2eb8:	9005      	str	r0, [sp, #20]
    2eba:	4650      	mov	r0, sl
    2ebc:	9400      	str	r4, [sp, #0]
    2ebe:	f7ff ff75 	bl	2dac <get_ip_port@@Base+0x374>
    2ec2:	bb60      	cbnz	r0, 2f1e <get_ip_port@@Base+0x4e6>
    2ec4:	f1a6 000d 	sub.w	r0, r6, #13
    2ec8:	fab0 f080 	clz	r0, r0
    2ecc:	0940      	lsrs	r0, r0, #5
    2ece:	4305      	orrs	r5, r0
    2ed0:	3601      	adds	r6, #1
    2ed2:	e7e3      	b.n	2e9c <get_ip_port@@Base+0x464>
    2ed4:	f046 0004 	orr.w	r0, r6, #4
    2ed8:	2805      	cmp	r0, #5
    2eda:	d120      	bne.n	2f1e <get_ip_port@@Base+0x4e6>
    2edc:	aa05      	add	r2, sp, #20
    2ede:	4650      	mov	r0, sl
    2ee0:	210d      	movs	r1, #13
    2ee2:	f000 fa19 	bl	3318 <get_ip_port@@Base+0x8e0>
    2ee6:	b9d0      	cbnz	r0, 2f1e <get_ip_port@@Base+0x4e6>
    2ee8:	ea4f 4518 	mov.w	r5, r8, lsr #16
    2eec:	fa15 f488 	uxtah	r4, r5, r8
    2ef0:	f10d 0808 	add.w	r8, sp, #8
    2ef4:	42a5      	cmp	r5, r4
    2ef6:	d21e      	bcs.n	2f36 <get_ip_port@@Base+0x4fe>
    2ef8:	9805      	ldr	r0, [sp, #20]
    2efa:	4633      	mov	r3, r6
    2efc:	f100 0208 	add.w	r2, r0, #8
    2f00:	6801      	ldr	r1, [r0, #0]
    2f02:	9205      	str	r2, [sp, #20]
    2f04:	462a      	mov	r2, r5
    2f06:	6840      	ldr	r0, [r0, #4]
    2f08:	f8cd 8000 	str.w	r8, [sp]
    2f0c:	e9cd 1002 	strd	r1, r0, [sp, #8]
    2f10:	4650      	mov	r0, sl
    2f12:	2101      	movs	r1, #1
    2f14:	f7ff ff4a 	bl	2dac <get_ip_port@@Base+0x374>
    2f18:	3501      	adds	r5, #1
    2f1a:	2800      	cmp	r0, #0
    2f1c:	d0ea      	beq.n	2ef4 <get_ip_port@@Base+0x4bc>
    2f1e:	2002      	movs	r0, #2
    2f20:	f8d9 1000 	ldr.w	r1, [r9]
    2f24:	9a06      	ldr	r2, [sp, #24]
    2f26:	1a89      	subs	r1, r1, r2
    2f28:	bf02      	ittt	eq
    2f2a:	b007      	addeq	sp, #28
    2f2c:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    2f30:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    2f32:	f7fe ea40 	blx	13b4 <__stack_chk_fail@plt>
    2f36:	2e01      	cmp	r6, #1
    2f38:	d107      	bne.n	2f4a <get_ip_port@@Base+0x512>
    2f3a:	9805      	ldr	r0, [sp, #20]
    2f3c:	1d02      	adds	r2, r0, #4
    2f3e:	9205      	str	r2, [sp, #20]
    2f40:	e006      	b.n	2f50 <get_ip_port@@Base+0x518>
    2f42:	07e8      	lsls	r0, r5, #31
    2f44:	d003      	beq.n	2f4e <get_ip_port@@Base+0x516>
    2f46:	2000      	movs	r0, #0
    2f48:	e7ea      	b.n	2f20 <get_ip_port@@Base+0x4e8>
    2f4a:	9a05      	ldr	r2, [sp, #20]
    2f4c:	e000      	b.n	2f50 <get_ip_port@@Base+0x518>
    2f4e:	9a02      	ldr	r2, [sp, #8]
    2f50:	4650      	mov	r0, sl
    2f52:	210d      	movs	r1, #13
    2f54:	f000 f9fa 	bl	334c <get_ip_port@@Base+0x914>
    2f58:	2800      	cmp	r0, #0
    2f5a:	bf18      	it	ne
    2f5c:	2001      	movne	r0, #1
    2f5e:	0040      	lsls	r0, r0, #1
    2f60:	e7de      	b.n	2f20 <get_ip_port@@Base+0x4e8>
    2f62:	480d      	ldr	r0, [pc, #52]	@ (2f98 <get_ip_port@@Base+0x560>)
    2f64:	f44f 716e 	mov.w	r1, #952	@ 0x3b8
    2f68:	4478      	add	r0, pc
    2f6a:	e9cd 1000 	strd	r1, r0, [sp]
    2f6e:	480b      	ldr	r0, [pc, #44]	@ (2f9c <get_ip_port@@Base+0x564>)
    2f70:	490b      	ldr	r1, [pc, #44]	@ (2fa0 <get_ip_port@@Base+0x568>)
    2f72:	4478      	add	r0, pc
    2f74:	4a0b      	ldr	r2, [pc, #44]	@ (2fa4 <get_ip_port@@Base+0x56c>)
    2f76:	4b0c      	ldr	r3, [pc, #48]	@ (2fa8 <get_ip_port@@Base+0x570>)
    2f78:	4479      	add	r1, pc
    2f7a:	6800      	ldr	r0, [r0, #0]
    2f7c:	447a      	add	r2, pc
    2f7e:	447b      	add	r3, pc
    2f80:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    2f84:	4620      	mov	r0, r4
    2f86:	f7fe eae8 	blx	1558 <fprintf@plt>
    2f8a:	4620      	mov	r0, r4
    2f8c:	f7fe eaea 	blx	1564 <fflush@plt>
    2f90:	f7fe eaee 	blx	1570 <abort@plt>
    2f94:	4064      	eors	r4, r4
    2f96:	0000      	movs	r0, r0
    2f98:	18f3      	adds	r3, r6, r3
    2f9a:	0000      	movs	r0, r0
    2f9c:	3fa2      	subs	r7, #162	@ 0xa2
    2f9e:	0000      	movs	r0, r0
    2fa0:	1813      	adds	r3, r2, r0
    2fa2:	0000      	movs	r0, r0
    2fa4:	18fa      	adds	r2, r7, r3
    2fa6:	0000      	movs	r0, r0
    2fa8:	1836      	adds	r6, r6, r0
    2faa:	0000      	movs	r0, r0
    2fac:	4608      	mov	r0, r1
    2fae:	4611      	mov	r1, r2
    2fb0:	f000 b800 	b.w	2fb4 <get_ip_port@@Base+0x57c>
    2fb4:	b5b0      	push	{r4, r5, r7, lr}
    2fb6:	af02      	add	r7, sp, #8
    2fb8:	4605      	mov	r5, r0
    2fba:	4608      	mov	r0, r1
    2fbc:	460c      	mov	r4, r1
    2fbe:	f000 f92b 	bl	3218 <get_ip_port@@Base+0x7e0>
    2fc2:	f895 1050 	ldrb.w	r1, [r5, #80]	@ 0x50
    2fc6:	07c9      	lsls	r1, r1, #31
    2fc8:	d103      	bne.n	2fd2 <get_ip_port@@Base+0x59a>
    2fca:	6800      	ldr	r0, [r0, #0]
    2fcc:	b108      	cbz	r0, 2fd2 <get_ip_port@@Base+0x59a>
    2fce:	2009      	movs	r0, #9
    2fd0:	bdb0      	pop	{r4, r5, r7, pc}
    2fd2:	4620      	mov	r0, r4
    2fd4:	f000 fa18 	bl	3408 <get_ip_port@@Base+0x9d0>
    2fd8:	4601      	mov	r1, r0
    2fda:	2009      	movs	r0, #9
    2fdc:	2901      	cmp	r1, #1
    2fde:	bf08      	it	eq
    2fe0:	2008      	moveq	r0, #8
    2fe2:	bdb0      	pop	{r4, r5, r7, pc}
    2fe4:	4608      	mov	r0, r1
    2fe6:	4611      	mov	r1, r2
    2fe8:	f7ff bfe4 	b.w	2fb4 <get_ip_port@@Base+0x57c>
    2fec:	4608      	mov	r0, r1
    2fee:	4611      	mov	r1, r2
    2ff0:	f7ff bfe0 	b.w	2fb4 <get_ip_port@@Base+0x57c>
    2ff4:	b5f0      	push	{r4, r5, r6, r7, lr}
    2ff6:	af03      	add	r7, sp, #12
    2ff8:	f84d 8d04 	str.w	r8, [sp, #-4]!
    2ffc:	f5ad 6d09 	sub.w	sp, sp, #2192	@ 0x890
    3000:	4604      	mov	r4, r0
    3002:	4823      	ldr	r0, [pc, #140]	@ (3090 <get_ip_port@@Base+0x658>)
    3004:	f50d 6691 	add.w	r6, sp, #1160	@ 0x488
    3008:	4478      	add	r0, pc
    300a:	f8d0 8000 	ldr.w	r8, [r0]
    300e:	f8d8 0000 	ldr.w	r0, [r8]
    3012:	f847 0c14 	str.w	r0, [r7, #-20]
    3016:	4630      	mov	r0, r6
    3018:	f000 e942 	blx	32a0 <get_ip_port@@Base+0x868>
    301c:	ad0a      	add	r5, sp, #40	@ 0x28
    301e:	2000      	movs	r0, #0
    3020:	60e0      	str	r0, [r4, #12]
    3022:	4631      	mov	r1, r6
    3024:	4628      	mov	r0, r5
    3026:	f000 f953 	bl	32d0 <get_ip_port@@Base+0x898>
    302a:	466e      	mov	r6, sp
    302c:	4628      	mov	r0, r5
    302e:	4631      	mov	r1, r6
    3030:	f000 f9ed 	bl	340e <get_ip_port@@Base+0x9d6>
    3034:	b9a8      	cbnz	r0, 3062 <get_ip_port@@Base+0x62a>
    3036:	9b03      	ldr	r3, [sp, #12]
    3038:	2b00      	cmp	r3, #0
    303a:	d0f7      	beq.n	302c <get_ip_port@@Base+0x5f4>
    303c:	9800      	ldr	r0, [sp, #0]
    303e:	f104 0c48 	add.w	ip, r4, #72	@ 0x48
    3042:	9908      	ldr	r1, [sp, #32]
    3044:	9a05      	ldr	r2, [sp, #20]
    3046:	e8ac 0007 	stmia.w	ip!, {r0, r1, r2}
    304a:	2000      	movs	r0, #0
    304c:	4621      	mov	r1, r4
    304e:	462a      	mov	r2, r5
    3050:	4798      	blx	r3
    3052:	2808      	cmp	r0, #8
    3054:	d0ea      	beq.n	302c <get_ip_port@@Base+0x5f4>
    3056:	2806      	cmp	r0, #6
    3058:	d011      	beq.n	307e <get_ip_port@@Base+0x646>
    305a:	2809      	cmp	r0, #9
    305c:	d101      	bne.n	3062 <get_ip_port@@Base+0x62a>
    305e:	2009      	movs	r0, #9
    3060:	e000      	b.n	3064 <get_ip_port@@Base+0x62c>
    3062:	2003      	movs	r0, #3
    3064:	f8d8 1000 	ldr.w	r1, [r8]
    3068:	f857 2c14 	ldr.w	r2, [r7, #-20]
    306c:	1a89      	subs	r1, r1, r2
    306e:	bf02      	ittt	eq
    3070:	f50d 6d09 	addeq.w	sp, sp, #2192	@ 0x890
    3074:	f85d 8b04 	ldreq.w	r8, [sp], #4
    3078:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    307a:	f7fe e99c 	blx	13b4 <__stack_chk_fail@plt>
    307e:	f50d 6091 	add.w	r0, sp, #1160	@ 0x488
    3082:	a90a      	add	r1, sp, #40	@ 0x28
    3084:	4622      	mov	r2, r4
    3086:	2300      	movs	r3, #0
    3088:	f000 f804 	bl	3094 <get_ip_port@@Base+0x65c>
    308c:	2002      	movs	r0, #2
    308e:	e7e9      	b.n	3064 <get_ip_port@@Base+0x62c>
    3090:	3ec8      	subs	r6, #200	@ 0xc8
    3092:	0000      	movs	r0, r0
    3094:	b5f0      	push	{r4, r5, r6, r7, lr}
    3096:	af03      	add	r7, sp, #12
    3098:	e92d 0f00 	stmdb	sp!, {r8, r9, sl, fp}
    309c:	b08f      	sub	sp, #60	@ 0x3c
    309e:	460c      	mov	r4, r1
    30a0:	4601      	mov	r1, r0
    30a2:	483c      	ldr	r0, [pc, #240]	@ (3194 <get_ip_port@@Base+0x75c>)
    30a4:	469a      	mov	sl, r3
    30a6:	4615      	mov	r5, r2
    30a8:	4478      	add	r0, pc
    30aa:	f8d0 b000 	ldr.w	fp, [r0]
    30ae:	f8db 0000 	ldr.w	r0, [fp]
    30b2:	900e      	str	r0, [sp, #56]	@ 0x38
    30b4:	4620      	mov	r0, r4
    30b6:	f000 f90b 	bl	32d0 <get_ip_port@@Base+0x898>
    30ba:	f10d 090c 	add.w	r9, sp, #12
    30be:	f04f 0801 	mov.w	r8, #1
    30c2:	f01a 0001 	ands.w	r0, sl, #1
    30c6:	f04f 0601 	mov.w	r6, #1
    30ca:	bf18      	it	ne
    30cc:	2602      	movne	r6, #2
    30ce:	d00a      	beq.n	30e6 <get_ip_port@@Base+0x6ae>
    30d0:	f1b8 0f00 	cmp.w	r8, #0
    30d4:	d107      	bne.n	30e6 <get_ip_port@@Base+0x6ae>
    30d6:	692a      	ldr	r2, [r5, #16]
    30d8:	4620      	mov	r0, r4
    30da:	f04f 31ff 	mov.w	r1, #4294967295	@ 0xffffffff
    30de:	f000 f935 	bl	334c <get_ip_port@@Base+0x914>
    30e2:	f04f 0a00 	mov.w	sl, #0
    30e6:	aa0d      	add	r2, sp, #52	@ 0x34
    30e8:	4620      	mov	r0, r4
    30ea:	f06f 0101 	mvn.w	r1, #1
    30ee:	f000 f913 	bl	3318 <get_ip_port@@Base+0x8e0>
    30f2:	4620      	mov	r0, r4
    30f4:	4649      	mov	r1, r9
    30f6:	f000 f98a 	bl	340e <get_ip_port@@Base+0x9d6>
    30fa:	bb30      	cbnz	r0, 314a <get_ip_port@@Base+0x712>
    30fc:	9b06      	ldr	r3, [sp, #24]
    30fe:	b193      	cbz	r3, 3126 <get_ip_port@@Base+0x6ee>
    3100:	9803      	ldr	r0, [sp, #12]
    3102:	f105 0c48 	add.w	ip, r5, #72	@ 0x48
    3106:	990b      	ldr	r1, [sp, #44]	@ 0x2c
    3108:	9a08      	ldr	r2, [sp, #32]
    310a:	e8ac 0007 	stmia.w	ip!, {r0, r1, r2}
    310e:	4630      	mov	r0, r6
    3110:	4629      	mov	r1, r5
    3112:	4622      	mov	r2, r4
    3114:	4798      	blx	r3
    3116:	2807      	cmp	r0, #7
    3118:	d00c      	beq.n	3134 <get_ip_port@@Base+0x6fc>
    311a:	2808      	cmp	r0, #8
    311c:	d106      	bne.n	312c <get_ip_port@@Base+0x6f4>
    311e:	6a28      	ldr	r0, [r5, #32]
    3120:	990d      	ldr	r1, [sp, #52]	@ 0x34
    3122:	4281      	cmp	r1, r0
    3124:	d01c      	beq.n	3160 <get_ip_port@@Base+0x728>
    3126:	f1a8 0801 	sub.w	r8, r8, #1
    312a:	e7ca      	b.n	30c2 <get_ip_port@@Base+0x68a>
    312c:	2809      	cmp	r0, #9
    312e:	d10c      	bne.n	314a <get_ip_port@@Base+0x712>
    3130:	f7fe ea1e 	blx	1570 <abort@plt>
    3134:	aa02      	add	r2, sp, #8
    3136:	4620      	mov	r0, r4
    3138:	f04f 31ff 	mov.w	r1, #4294967295	@ 0xffffffff
    313c:	f000 f8ec 	bl	3318 <get_ip_port@@Base+0x8e0>
    3140:	9802      	ldr	r0, [sp, #8]
    3142:	6128      	str	r0, [r5, #16]
    3144:	4620      	mov	r0, r4
    3146:	f000 f973 	bl	3430 <get_ip_port@@Base+0x9f8>
    314a:	f8db 0000 	ldr.w	r0, [fp]
    314e:	990e      	ldr	r1, [sp, #56]	@ 0x38
    3150:	1a40      	subs	r0, r0, r1
    3152:	bf02      	ittt	eq
    3154:	b00f      	addeq	sp, #60	@ 0x3c
    3156:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    315a:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    315c:	f7fe e92a 	blx	13b4 <__stack_chk_fail@plt>
    3160:	480d      	ldr	r0, [pc, #52]	@ (3198 <get_ip_port@@Base+0x760>)
    3162:	f44f 711a 	mov.w	r1, #616	@ 0x268
    3166:	4478      	add	r0, pc
    3168:	e9cd 1000 	strd	r1, r0, [sp]
    316c:	480b      	ldr	r0, [pc, #44]	@ (319c <get_ip_port@@Base+0x764>)
    316e:	490c      	ldr	r1, [pc, #48]	@ (31a0 <get_ip_port@@Base+0x768>)
    3170:	4478      	add	r0, pc
    3172:	4a0c      	ldr	r2, [pc, #48]	@ (31a4 <get_ip_port@@Base+0x76c>)
    3174:	4b0c      	ldr	r3, [pc, #48]	@ (31a8 <get_ip_port@@Base+0x770>)
    3176:	4479      	add	r1, pc
    3178:	6800      	ldr	r0, [r0, #0]
    317a:	447a      	add	r2, pc
    317c:	447b      	add	r3, pc
    317e:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    3182:	4620      	mov	r0, r4
    3184:	f7fe e9e8 	blx	1558 <fprintf@plt>
    3188:	4620      	mov	r0, r4
    318a:	f7fe e9ec 	blx	1564 <fflush@plt>
    318e:	f7fe e9f0 	blx	1570 <abort@plt>
    3192:	bf00      	nop
    3194:	3e28      	subs	r6, #40	@ 0x28
    3196:	0000      	movs	r0, r0
    3198:	172e      	asrs	r6, r5, #28
    319a:	0000      	movs	r0, r0
    319c:	3da4      	subs	r5, #164	@ 0xa4
    319e:	0000      	movs	r0, r0
    31a0:	1615      	asrs	r5, r2, #24
    31a2:	0000      	movs	r0, r0
    31a4:	170c      	asrs	r4, r1, #28
    31a6:	0000      	movs	r0, r0
    31a8:	1638      	asrs	r0, r7, #24
    31aa:	0000      	movs	r0, r0
    31ac:	4770      	bx	lr
    31ae:	0000      	movs	r0, r0
    31b0:	b5b0      	push	{r4, r5, r7, lr}
    31b2:	af02      	add	r7, sp, #8
    31b4:	f5ad 6d06 	sub.w	sp, sp, #2144	@ 0x860
    31b8:	b082      	sub	sp, #8
    31ba:	f50d 658d 	add.w	r5, sp, #1128	@ 0x468
    31be:	4604      	mov	r4, r0
    31c0:	4628      	mov	r0, r5
    31c2:	f000 e86e 	blx	32a0 <get_ip_port@@Base+0x868>
    31c6:	a902      	add	r1, sp, #8
    31c8:	4628      	mov	r0, r5
    31ca:	4622      	mov	r2, r4
    31cc:	2301      	movs	r3, #1
    31ce:	f7ff ff61 	bl	3094 <get_ip_port@@Base+0x65c>
    31d2:	480c      	ldr	r0, [pc, #48]	@ (3204 <get_ip_port@@Base+0x7cc>)
    31d4:	f240 21ce 	movw	r1, #718	@ 0x2ce
    31d8:	4478      	add	r0, pc
    31da:	e9cd 1000 	strd	r1, r0, [sp]
    31de:	480a      	ldr	r0, [pc, #40]	@ (3208 <get_ip_port@@Base+0x7d0>)
    31e0:	490a      	ldr	r1, [pc, #40]	@ (320c <get_ip_port@@Base+0x7d4>)
    31e2:	4478      	add	r0, pc
    31e4:	4a0a      	ldr	r2, [pc, #40]	@ (3210 <get_ip_port@@Base+0x7d8>)
    31e6:	4b0b      	ldr	r3, [pc, #44]	@ (3214 <get_ip_port@@Base+0x7dc>)
    31e8:	4479      	add	r1, pc
    31ea:	6800      	ldr	r0, [r0, #0]
    31ec:	447a      	add	r2, pc
    31ee:	447b      	add	r3, pc
    31f0:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    31f4:	4620      	mov	r0, r4
    31f6:	f7fe e9b0 	blx	1558 <fprintf@plt>
    31fa:	4620      	mov	r0, r4
    31fc:	f7fe e9b2 	blx	1564 <fflush@plt>
    3200:	f7fe e9b6 	blx	1570 <abort@plt>
    3204:	1655      	asrs	r5, r2, #25
    3206:	0000      	movs	r0, r0
    3208:	3d32      	subs	r5, #50	@ 0x32
    320a:	0000      	movs	r0, r0
    320c:	15a3      	asrs	r3, r4, #22
    320e:	0000      	movs	r0, r0
    3210:	15b9      	asrs	r1, r7, #22
    3212:	0000      	movs	r0, r0
    3214:	15c6      	asrs	r6, r0, #23
    3216:	0000      	movs	r0, r0
    3218:	b5d0      	push	{r4, r6, r7, lr}
    321a:	af02      	add	r7, sp, #8
    321c:	b08c      	sub	sp, #48	@ 0x30
    321e:	490a      	ldr	r1, [pc, #40]	@ (3248 <get_ip_port@@Base+0x810>)
    3220:	4479      	add	r1, pc
    3222:	680c      	ldr	r4, [r1, #0]
    3224:	6821      	ldr	r1, [r4, #0]
    3226:	910b      	str	r1, [sp, #44]	@ 0x2c
    3228:	a901      	add	r1, sp, #4
    322a:	f000 f8f0 	bl	340e <get_ip_port@@Base+0x9d6>
    322e:	4601      	mov	r1, r0
    3230:	9803      	ldr	r0, [sp, #12]
    3232:	2900      	cmp	r1, #0
    3234:	bf18      	it	ne
    3236:	2000      	movne	r0, #0
    3238:	6821      	ldr	r1, [r4, #0]
    323a:	9a0b      	ldr	r2, [sp, #44]	@ 0x2c
    323c:	1a89      	subs	r1, r1, r2
    323e:	bf04      	itt	eq
    3240:	b00c      	addeq	sp, #48	@ 0x30
    3242:	bdd0      	popeq	{r4, r6, r7, pc}
    3244:	f7fe e8b6 	blx	13b4 <__stack_chk_fail@plt>
    3248:	3cb0      	subs	r4, #176	@ 0xb0
    324a:	0000      	movs	r0, r0
    324c:	b5d0      	push	{r4, r6, r7, lr}
    324e:	af02      	add	r7, sp, #8
    3250:	b08c      	sub	sp, #48	@ 0x30
    3252:	490a      	ldr	r1, [pc, #40]	@ (327c <get_ip_port@@Base+0x844>)
    3254:	4479      	add	r1, pc
    3256:	680c      	ldr	r4, [r1, #0]
    3258:	6821      	ldr	r1, [r4, #0]
    325a:	910b      	str	r1, [sp, #44]	@ 0x2c
    325c:	a901      	add	r1, sp, #4
    325e:	f000 f8d6 	bl	340e <get_ip_port@@Base+0x9d6>
    3262:	4601      	mov	r1, r0
    3264:	9801      	ldr	r0, [sp, #4]
    3266:	2900      	cmp	r1, #0
    3268:	bf18      	it	ne
    326a:	2000      	movne	r0, #0
    326c:	6821      	ldr	r1, [r4, #0]
    326e:	9a0b      	ldr	r2, [sp, #44]	@ 0x2c
    3270:	1a89      	subs	r1, r1, r2
    3272:	bf04      	itt	eq
    3274:	b00c      	addeq	sp, #48	@ 0x30
    3276:	bdd0      	popeq	{r4, r6, r7, pc}
    3278:	f7fe e89c 	blx	13b4 <__stack_chk_fail@plt>
    327c:	3c7c      	subs	r4, #124	@ 0x7c
    327e:	0000      	movs	r0, r0
    3280:	6882      	ldr	r2, [r0, #8]
    3282:	b112      	cbz	r2, 328a <get_ip_port@@Base+0x852>
    3284:	4601      	mov	r1, r0
    3286:	2001      	movs	r0, #1
    3288:	4710      	bx	r2
    328a:	4770      	bx	lr
    328c:	b580      	push	{r7, lr}
    328e:	466f      	mov	r7, sp
    3290:	4608      	mov	r0, r1
    3292:	f000 f8b9 	bl	3408 <get_ip_port@@Base+0x9d0>
    3296:	3801      	subs	r0, #1
    3298:	bf18      	it	ne
    329a:	2009      	movne	r0, #9
    329c:	bd80      	pop	{r7, pc}
    329e:	0000      	movs	r0, r0
    32a0:	1fff      	subs	r7, r7, #7
    32a2:	e880 d034 	stmia.w	r0, {r2, r4, r5, ip, lr, pc}
    32a6:	e580      	b.n	2daa <get_ip_port@@Base+0x372>
    32a8:	e038      	b.n	331c <get_ip_port@@Base+0x8e4>
    32aa:	e580      	b.n	2dae <get_ip_port@@Base+0x376>
    32ac:	e03c      	b.n	3328 <get_ip_port@@Base+0x8f0>
    32ae:	e580      	b.n	2db2 <get_ip_port@@Base+0x37a>
    32b0:	0000      	movs	r0, r0
    32b2:	e3a0      	b.n	39f6 <get_ip_port@@Base+0xfbe>
    32b4:	ff1e e12f 	vrhadd.u16	d14, d14, d31
    32b8:	0b20      	lsrs	r0, r4, #12
    32ba:	ec80 ff1e 	stc	15, cr15, [r0], {30}
    32be:	e12f      	b.n	3520 <get_ip_port@@Base+0xae8>
    32c0:	0b20      	lsrs	r0, r4, #12
    32c2:	ec80 ff1e 	stc	15, cr15, [r0], {30}
    32c6:	e12f      	b.n	3528 <get_ip_port@@Base+0xaf0>
    32c8:	0b20      	lsrs	r0, r4, #12
    32ca:	ecc0 ff1e 	stcl	15, cr15, [r0], {30}
    32ce:	e12f      	b.n	3530 <get_ip_port@@Base+0xaf8>
    32d0:	b5d0      	push	{r4, r6, r7, lr}
    32d2:	af02      	add	r7, sp, #8
    32d4:	4604      	mov	r4, r0
    32d6:	2000      	movs	r0, #0
    32d8:	f884 004a 	strb.w	r0, [r4, #74]	@ 0x4a
    32dc:	f8a4 0048 	strh.w	r0, [r4, #72]	@ 0x48
    32e0:	480b      	ldr	r0, [pc, #44]	@ (3310 <get_ip_port@@Base+0x8d8>)
    32e2:	4a0c      	ldr	r2, [pc, #48]	@ (3314 <get_ip_port@@Base+0x8dc>)
    32e4:	4478      	add	r0, pc
    32e6:	447a      	add	r2, pc
    32e8:	3208      	adds	r2, #8
    32ea:	e9c4 2000 	strd	r2, r0, [r4]
    32ee:	f104 0008 	add.w	r0, r4, #8
    32f2:	2240      	movs	r2, #64	@ 0x40
    32f4:	f7fe e918 	blx	1528 <__aeabi_memcpy@plt>
    32f8:	f104 0050 	add.w	r0, r4, #80	@ 0x50
    32fc:	f44f 7199 	mov.w	r1, #306	@ 0x132
    3300:	f7fe e8ca 	blx	1498 <__aeabi_memclr@plt>
    3304:	4620      	mov	r0, r4
    3306:	2100      	movs	r1, #0
    3308:	f000 f92a 	bl	3560 <get_ip_port@@Base+0xb28>
    330c:	2000      	movs	r0, #0
    330e:	bdd0      	pop	{r4, r6, r7, pc}
    3310:	3d20      	subs	r5, #32
    3312:	0000      	movs	r0, r0
    3314:	3a86      	subs	r2, #134	@ 0x86
    3316:	0000      	movs	r0, r0
    3318:	b5f0      	push	{r4, r5, r6, r7, lr}
    331a:	af03      	add	r7, sp, #12
    331c:	f84d bd04 	str.w	fp, [sp, #-4]!
    3320:	4606      	mov	r6, r0
    3322:	6800      	ldr	r0, [r0, #0]
    3324:	4614      	mov	r4, r2
    3326:	460d      	mov	r5, r1
    3328:	6882      	ldr	r2, [r0, #8]
    332a:	4630      	mov	r0, r6
    332c:	4790      	blx	r2
    332e:	b138      	cbz	r0, 3340 <get_ip_port@@Base+0x908>
    3330:	6830      	ldr	r0, [r6, #0]
    3332:	4629      	mov	r1, r5
    3334:	68c2      	ldr	r2, [r0, #12]
    3336:	4630      	mov	r0, r6
    3338:	4790      	blx	r2
    333a:	6020      	str	r0, [r4, #0]
    333c:	2000      	movs	r0, #0
    333e:	e000      	b.n	3342 <get_ip_port@@Base+0x90a>
    3340:	4801      	ldr	r0, [pc, #4]	@ (3348 <get_ip_port@@Base+0x910>)
    3342:	f85d bb04 	ldr.w	fp, [sp], #4
    3346:	bdf0      	pop	{r4, r5, r6, r7, pc}
    3348:	e672      	b.n	3030 <get_ip_port@@Base+0x5f8>
    334a:	ffff b5f0 	vsli.64	<illegal reg q13.5>, q8, #63	@ 0x3f
    334e:	af03      	add	r7, sp, #12
    3350:	f84d bd04 	str.w	fp, [sp, #-4]!
    3354:	4604      	mov	r4, r0
    3356:	6800      	ldr	r0, [r0, #0]
    3358:	4616      	mov	r6, r2
    335a:	460d      	mov	r5, r1
    335c:	6882      	ldr	r2, [r0, #8]
    335e:	4620      	mov	r0, r4
    3360:	4790      	blx	r2
    3362:	b148      	cbz	r0, 3378 <get_ip_port@@Base+0x940>
    3364:	6820      	ldr	r0, [r4, #0]
    3366:	4629      	mov	r1, r5
    3368:	4632      	mov	r2, r6
    336a:	6903      	ldr	r3, [r0, #16]
    336c:	4620      	mov	r0, r4
    336e:	4798      	blx	r3
    3370:	1c68      	adds	r0, r5, #1
    3372:	d003      	beq.n	337c <get_ip_port@@Base+0x944>
    3374:	2500      	movs	r5, #0
    3376:	e007      	b.n	3388 <get_ip_port@@Base+0x950>
    3378:	4d05      	ldr	r5, [pc, #20]	@ (3390 <get_ip_port@@Base+0x958>)
    337a:	e005      	b.n	3388 <get_ip_port@@Base+0x950>
    337c:	6820      	ldr	r0, [r4, #0]
    337e:	2100      	movs	r1, #0
    3380:	2500      	movs	r5, #0
    3382:	6b42      	ldr	r2, [r0, #52]	@ 0x34
    3384:	4620      	mov	r0, r4
    3386:	4790      	blx	r2
    3388:	4628      	mov	r0, r5
    338a:	f85d bb04 	ldr.w	fp, [sp], #4
    338e:	bdf0      	pop	{r4, r5, r6, r7, pc}
    3390:	e672      	b.n	3078 <get_ip_port@@Base+0x640>
    3392:	ffff b5f0 	vsli.64	<illegal reg q13.5>, q8, #63	@ 0x3f
    3396:	af03      	add	r7, sp, #12
    3398:	f84d bd04 	str.w	fp, [sp, #-4]!
    339c:	4606      	mov	r6, r0
    339e:	6800      	ldr	r0, [r0, #0]
    33a0:	4614      	mov	r4, r2
    33a2:	460d      	mov	r5, r1
    33a4:	6942      	ldr	r2, [r0, #20]
    33a6:	4630      	mov	r0, r6
    33a8:	4790      	blx	r2
    33aa:	b140      	cbz	r0, 33be <get_ip_port@@Base+0x986>
    33ac:	6830      	ldr	r0, [r6, #0]
    33ae:	4629      	mov	r1, r5
    33b0:	6982      	ldr	r2, [r0, #24]
    33b2:	4630      	mov	r0, r6
    33b4:	4790      	blx	r2
    33b6:	e9c4 0100 	strd	r0, r1, [r4]
    33ba:	2000      	movs	r0, #0
    33bc:	e000      	b.n	33c0 <get_ip_port@@Base+0x988>
    33be:	4802      	ldr	r0, [pc, #8]	@ (33c8 <get_ip_port@@Base+0x990>)
    33c0:	f85d bb04 	ldr.w	fp, [sp], #4
    33c4:	bdf0      	pop	{r4, r5, r6, r7, pc}
    33c6:	bf00      	nop
    33c8:	e672      	b.n	30b0 <get_ip_port@@Base+0x678>
    33ca:	ffff b5f0 	vsli.64	<illegal reg q13.5>, q8, #63	@ 0x3f
    33ce:	af03      	add	r7, sp, #12
    33d0:	f84d 8d04 	str.w	r8, [sp, #-4]!
    33d4:	4604      	mov	r4, r0
    33d6:	6800      	ldr	r0, [r0, #0]
    33d8:	4615      	mov	r5, r2
    33da:	4698      	mov	r8, r3
    33dc:	460e      	mov	r6, r1
    33de:	6942      	ldr	r2, [r0, #20]
    33e0:	4620      	mov	r0, r4
    33e2:	4790      	blx	r2
    33e4:	b148      	cbz	r0, 33fa <get_ip_port@@Base+0x9c2>
    33e6:	6820      	ldr	r0, [r4, #0]
    33e8:	4631      	mov	r1, r6
    33ea:	462a      	mov	r2, r5
    33ec:	4643      	mov	r3, r8
    33ee:	f8d0 c01c 	ldr.w	ip, [r0, #28]
    33f2:	4620      	mov	r0, r4
    33f4:	47e0      	blx	ip
    33f6:	2000      	movs	r0, #0
    33f8:	e000      	b.n	33fc <get_ip_port@@Base+0x9c4>
    33fa:	4802      	ldr	r0, [pc, #8]	@ (3404 <get_ip_port@@Base+0x9cc>)
    33fc:	f85d 8b04 	ldr.w	r8, [sp], #4
    3400:	bdf0      	pop	{r4, r5, r6, r7, pc}
    3402:	bf00      	nop
    3404:	e672      	b.n	30ec <get_ip_port@@Base+0x6b4>
    3406:	ffff 6801 	vtbl.8	d22, {d15}, d1
    340a:	6a09      	ldr	r1, [r1, #32]
    340c:	4708      	bx	r1
    340e:	b5d0      	push	{r4, r6, r7, lr}
    3410:	af02      	add	r7, sp, #8
    3412:	460c      	mov	r4, r1
    3414:	6801      	ldr	r1, [r0, #0]
    3416:	6a4a      	ldr	r2, [r1, #36]	@ 0x24
    3418:	4621      	mov	r1, r4
    341a:	4790      	blx	r2
    341c:	6861      	ldr	r1, [r4, #4]
    341e:	2000      	movs	r0, #0
    3420:	2900      	cmp	r1, #0
    3422:	bf04      	itt	eq
    3424:	f24e 606b 	movweq	r0, #58987	@ 0xe66b
    3428:	f6cf 70ff 	movteq	r0, #65535	@ 0xffff
    342c:	bdd0      	pop	{r4, r6, r7, pc}
    342e:	0000      	movs	r0, r0
    3430:	b580      	push	{r7, lr}
    3432:	466f      	mov	r7, sp
    3434:	6801      	ldr	r1, [r0, #0]
    3436:	6a89      	ldr	r1, [r1, #40]	@ 0x28
    3438:	4788      	blx	r1
    343a:	4801      	ldr	r0, [pc, #4]	@ (3440 <get_ip_port@@Base+0xa08>)
    343c:	bd80      	pop	{r7, pc}
    343e:	bf00      	nop
    3440:	e674      	b.n	312c <get_ip_port@@Base+0x6f4>
    3442:	ffff b5d0 	vsli.64	<illegal reg q13.5>, q0, #63	@ 0x3f
    3446:	af02      	add	r7, sp, #8
    3448:	6804      	ldr	r4, [r0, #0]
    344a:	6b24      	ldr	r4, [r4, #48]	@ 0x30
    344c:	47a0      	blx	r4
    344e:	4903      	ldr	r1, [pc, #12]	@ (345c <get_ip_port@@Base+0xa24>)
    3450:	2800      	cmp	r0, #0
    3452:	bf18      	it	ne
    3454:	2100      	movne	r1, #0
    3456:	4608      	mov	r0, r1
    3458:	bdd0      	pop	{r4, r6, r7, pc}
    345a:	bf00      	nop
    345c:	e674      	b.n	3148 <get_ip_port@@Base+0x710>
    345e:	ffff b580 	vabal.u<illegal width 64>	<illegal reg q13.5>, d31, d0
    3462:	466f      	mov	r7, sp
    3464:	6802      	ldr	r2, [r0, #0]
    3466:	6952      	ldr	r2, [r2, #20]
    3468:	4790      	blx	r2
    346a:	bd80      	pop	{r7, pc}
    346c:	6802      	ldr	r2, [r0, #0]
    346e:	6b92      	ldr	r2, [r2, #56]	@ 0x38
    3470:	4710      	bx	r2
    3472:	b580      	push	{r7, lr}
    3474:	466f      	mov	r7, sp
    3476:	6801      	ldr	r1, [r0, #0]
    3478:	6ac9      	ldr	r1, [r1, #44]	@ 0x2c
    347a:	4788      	blx	r1
    347c:	bd80      	pop	{r7, pc}
    347e:	6801      	ldr	r1, [r0, #0]
    3480:	6bc9      	ldr	r1, [r1, #60]	@ 0x3c
    3482:	4708      	bx	r1
    3484:	4770      	bx	lr
    3486:	4770      	bx	lr
    3488:	3910      	subs	r1, #16
    348a:	2000      	movs	r0, #0
    348c:	f111 0f13 	cmn.w	r1, #19
    3490:	bf88      	it	hi
    3492:	2001      	movhi	r0, #1
    3494:	4770      	bx	lr
    3496:	3008      	adds	r0, #8
    3498:	f000 b89c 	b.w	35d4 <get_ip_port@@Base+0xb9c>
    349c:	3008      	adds	r0, #8
    349e:	f000 b8d5 	b.w	364c <get_ip_port@@Base+0xc14>
    34a2:	f021 001f 	bic.w	r0, r1, #31
    34a6:	f5a0 7080 	sub.w	r0, r0, #256	@ 0x100
    34aa:	fab0 f080 	clz	r0, r0
    34ae:	0940      	lsrs	r0, r0, #5
    34b0:	4770      	bx	lr
    34b2:	3008      	adds	r0, #8
    34b4:	f000 b904 	b.w	36c0 <get_ip_port@@Base+0xc88>
    34b8:	3008      	adds	r0, #8
    34ba:	f000 b957 	b.w	376c <get_ip_port@@Base+0xd34>
    34be:	b5d0      	push	{r4, r6, r7, lr}
    34c0:	af02      	add	r7, sp, #8
    34c2:	4604      	mov	r4, r0
    34c4:	f890 0180 	ldrb.w	r0, [r0, #384]	@ 0x180
    34c8:	b108      	cbz	r0, 34ce <get_ip_port@@Base+0xa96>
    34ca:	2000      	movs	r0, #0
    34cc:	bdd0      	pop	{r4, r6, r7, pc}
    34ce:	4620      	mov	r0, r4
    34d0:	f000 f9aa 	bl	3828 <get_ip_port@@Base+0xdf0>
    34d4:	2801      	cmp	r0, #1
    34d6:	d11b      	bne.n	3510 <get_ip_port@@Base+0xad8>
    34d8:	6820      	ldr	r0, [r4, #0]
    34da:	2101      	movs	r1, #1
    34dc:	6b42      	ldr	r2, [r0, #52]	@ 0x34
    34de:	4620      	mov	r0, r4
    34e0:	4790      	blx	r2
    34e2:	f894 0180 	ldrb.w	r0, [r4, #384]	@ 0x180
    34e6:	2800      	cmp	r0, #0
    34e8:	d1ef      	bne.n	34ca <get_ip_port@@Base+0xa92>
    34ea:	f8d4 0168 	ldr.w	r0, [r4, #360]	@ 0x168
    34ee:	b170      	cbz	r0, 350e <get_ip_port@@Base+0xad6>
    34f0:	6820      	ldr	r0, [r4, #0]
    34f2:	f06f 0101 	mvn.w	r1, #1
    34f6:	68c2      	ldr	r2, [r0, #12]
    34f8:	4620      	mov	r0, r4
    34fa:	4790      	blx	r2
    34fc:	6821      	ldr	r1, [r4, #0]
    34fe:	f8d4 2168 	ldr.w	r2, [r4, #360]	@ 0x168
    3502:	690b      	ldr	r3, [r1, #16]
    3504:	4402      	add	r2, r0
    3506:	4620      	mov	r0, r4
    3508:	f06f 0101 	mvn.w	r1, #1
    350c:	4798      	blx	r3
    350e:	2001      	movs	r0, #1
    3510:	bdd0      	pop	{r4, r6, r7, pc}
    3512:	460a      	mov	r2, r1
    3514:	f500 71ac 	add.w	r1, r0, #344	@ 0x158
    3518:	4610      	mov	r0, r2
    351a:	2228      	movs	r2, #40	@ 0x28
    351c:	f000 bdfc 	b.w	4118 <get_ip_port@@Base+0x16e0>
    3520:	3008      	adds	r0, #8
    3522:	f000 b9a7 	b.w	3874 <get_ip_port@@Base+0xe3c>
    3526:	f890 0181 	ldrb.w	r0, [r0, #385]	@ 0x181
    352a:	4770      	bx	lr
    352c:	b5f0      	push	{r4, r5, r6, r7, lr}
    352e:	af03      	add	r7, sp, #12
    3530:	f84d 8d04 	str.w	r8, [sp, #-4]!
    3534:	b082      	sub	sp, #8
    3536:	460e      	mov	r6, r1
    3538:	e9d0 1500 	ldrd	r1, r5, [r0]
    353c:	4690      	mov	r8, r2
    353e:	461c      	mov	r4, r3
    3540:	68ca      	ldr	r2, [r1, #12]
    3542:	f04f 31ff 	mov.w	r1, #4294967295	@ 0xffffffff
    3546:	4790      	blx	r2
    3548:	4601      	mov	r1, r0
    354a:	4628      	mov	r0, r5
    354c:	4632      	mov	r2, r6
    354e:	4643      	mov	r3, r8
    3550:	9400      	str	r4, [sp, #0]
    3552:	f000 f9b3 	bl	38bc <get_ip_port@@Base+0xe84>
    3556:	b002      	add	sp, #8
    3558:	f85d 8b04 	ldr.w	r8, [sp], #4
    355c:	bdf0      	pop	{r4, r5, r6, r7, pc}
    355e:	0000      	movs	r0, r0
    3560:	b5f0      	push	{r4, r5, r6, r7, lr}
    3562:	af03      	add	r7, sp, #12
    3564:	f84d bd04 	str.w	fp, [sp, #-4]!
    3568:	b084      	sub	sp, #16
    356a:	4604      	mov	r4, r0
    356c:	4814      	ldr	r0, [pc, #80]	@ (35c0 <get_ip_port@@Base+0xb88>)
    356e:	460d      	mov	r5, r1
    3570:	f04f 31ff 	mov.w	r1, #4294967295	@ 0xffffffff
    3574:	4478      	add	r0, pc
    3576:	6806      	ldr	r6, [r0, #0]
    3578:	6830      	ldr	r0, [r6, #0]
    357a:	9003      	str	r0, [sp, #12]
    357c:	6820      	ldr	r0, [r4, #0]
    357e:	68c2      	ldr	r2, [r0, #12]
    3580:	4620      	mov	r0, r4
    3582:	4790      	blx	r2
    3584:	f020 0001 	bic.w	r0, r0, #1
    3588:	aa01      	add	r2, sp, #4
    358a:	1b45      	subs	r5, r0, r5
    358c:	6860      	ldr	r0, [r4, #4]
    358e:	4629      	mov	r1, r5
    3590:	f000 f9c4 	bl	391c <get_ip_port@@Base+0xee4>
    3594:	b138      	cbz	r0, 35a6 <get_ip_port@@Base+0xb6e>
    3596:	9801      	ldr	r0, [sp, #4]
    3598:	b128      	cbz	r0, 35a6 <get_ip_port@@Base+0xb6e>
    359a:	aa01      	add	r2, sp, #4
    359c:	4620      	mov	r0, r4
    359e:	4629      	mov	r1, r5
    35a0:	f000 f9de 	bl	3960 <get_ip_port@@Base+0xf28>
    35a4:	b910      	cbnz	r0, 35ac <get_ip_port@@Base+0xb74>
    35a6:	2001      	movs	r0, #1
    35a8:	f884 0180 	strb.w	r0, [r4, #384]	@ 0x180
    35ac:	6830      	ldr	r0, [r6, #0]
    35ae:	9903      	ldr	r1, [sp, #12]
    35b0:	1a40      	subs	r0, r0, r1
    35b2:	bf02      	ittt	eq
    35b4:	b004      	addeq	sp, #16
    35b6:	f85d bb04 	ldreq.w	fp, [sp], #4
    35ba:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    35bc:	f7fd eefa 	blx	13b4 <__stack_chk_fail@plt>
    35c0:	395c      	subs	r1, #92	@ 0x5c
    35c2:	0000      	movs	r0, r0
    35c4:	3008      	adds	r0, #8
    35c6:	f000 bae1 	b.w	3b8c <get_ip_port@@Base+0x1154>
    35ca:	2101      	movs	r1, #1
    35cc:	f880 1048 	strb.w	r1, [r0, #72]	@ 0x48
    35d0:	4770      	bx	lr
    35d2:	0000      	movs	r0, r0
    35d4:	b5dc      	push	{r2, r3, r4, r6, r7, lr}
    35d6:	af04      	add	r7, sp, #16
    35d8:	1c8a      	adds	r2, r1, #2
    35da:	d009      	beq.n	35f0 <get_ip_port@@Base+0xbb8>
    35dc:	1c4a      	adds	r2, r1, #1
    35de:	bf18      	it	ne
    35e0:	290f      	cmpne	r1, #15
    35e2:	d101      	bne.n	35e8 <get_ip_port@@Base+0xbb0>
    35e4:	303c      	adds	r0, #60	@ 0x3c
    35e6:	e00b      	b.n	3600 <get_ip_port@@Base+0xbc8>
    35e8:	290e      	cmp	r1, #14
    35ea:	d003      	beq.n	35f4 <get_ip_port@@Base+0xbbc>
    35ec:	290d      	cmp	r1, #13
    35ee:	d103      	bne.n	35f8 <get_ip_port@@Base+0xbc0>
    35f0:	3034      	adds	r0, #52	@ 0x34
    35f2:	e005      	b.n	3600 <get_ip_port@@Base+0xbc8>
    35f4:	3038      	adds	r0, #56	@ 0x38
    35f6:	e003      	b.n	3600 <get_ip_port@@Base+0xbc8>
    35f8:	290c      	cmp	r1, #12
    35fa:	d804      	bhi.n	3606 <get_ip_port@@Base+0xbce>
    35fc:	eb00 0081 	add.w	r0, r0, r1, lsl #2
    3600:	6800      	ldr	r0, [r0, #0]
    3602:	b002      	add	sp, #8
    3604:	bdd0      	pop	{r4, r6, r7, pc}
    3606:	480c      	ldr	r0, [pc, #48]	@ (3638 <get_ip_port@@Base+0xc00>)
    3608:	f240 51db 	movw	r1, #1499	@ 0x5db
    360c:	4478      	add	r0, pc
    360e:	e9cd 1000 	strd	r1, r0, [sp]
    3612:	480a      	ldr	r0, [pc, #40]	@ (363c <get_ip_port@@Base+0xc04>)
    3614:	490a      	ldr	r1, [pc, #40]	@ (3640 <get_ip_port@@Base+0xc08>)
    3616:	4478      	add	r0, pc
    3618:	4a0a      	ldr	r2, [pc, #40]	@ (3644 <get_ip_port@@Base+0xc0c>)
    361a:	4b0b      	ldr	r3, [pc, #44]	@ (3648 <get_ip_port@@Base+0xc10>)
    361c:	4479      	add	r1, pc
    361e:	6800      	ldr	r0, [r0, #0]
    3620:	447a      	add	r2, pc
    3622:	447b      	add	r3, pc
    3624:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    3628:	4620      	mov	r0, r4
    362a:	f7fd ef96 	blx	1558 <fprintf@plt>
    362e:	4620      	mov	r0, r4
    3630:	f7fd ef98 	blx	1564 <fflush@plt>
    3634:	f7fd ef9c 	blx	1570 <abort@plt>
    3638:	13ff      	asrs	r7, r7, #15
    363a:	0000      	movs	r0, r0
    363c:	38fe      	subs	r0, #254	@ 0xfe
    363e:	0000      	movs	r0, r0
    3640:	116f      	asrs	r7, r5, #5
    3642:	0000      	movs	r0, r0
    3644:	1369      	asrs	r1, r5, #13
    3646:	0000      	movs	r0, r0
    3648:	1373      	asrs	r3, r6, #13
    364a:	0000      	movs	r0, r0
    364c:	b5dc      	push	{r2, r3, r4, r6, r7, lr}
    364e:	af04      	add	r7, sp, #16
    3650:	1c8b      	adds	r3, r1, #2
    3652:	d009      	beq.n	3668 <get_ip_port@@Base+0xc30>
    3654:	1c4b      	adds	r3, r1, #1
    3656:	bf18      	it	ne
    3658:	290f      	cmpne	r1, #15
    365a:	d101      	bne.n	3660 <get_ip_port@@Base+0xc28>
    365c:	63c2      	str	r2, [r0, #60]	@ 0x3c
    365e:	bddc      	pop	{r2, r3, r4, r6, r7, pc}
    3660:	290e      	cmp	r1, #14
    3662:	d003      	beq.n	366c <get_ip_port@@Base+0xc34>
    3664:	290d      	cmp	r1, #13
    3666:	d103      	bne.n	3670 <get_ip_port@@Base+0xc38>
    3668:	6342      	str	r2, [r0, #52]	@ 0x34
    366a:	bddc      	pop	{r2, r3, r4, r6, r7, pc}
    366c:	6382      	str	r2, [r0, #56]	@ 0x38
    366e:	bddc      	pop	{r2, r3, r4, r6, r7, pc}
    3670:	290c      	cmp	r1, #12
    3672:	bf9c      	itt	ls
    3674:	f840 2021 	strls.w	r2, [r0, r1, lsl #2]
    3678:	bddc      	popls	{r2, r3, r4, r6, r7, pc}
    367a:	480c      	ldr	r0, [pc, #48]	@ (36ac <get_ip_port@@Base+0xc74>)
    367c:	f240 51fe 	movw	r1, #1534	@ 0x5fe
    3680:	4478      	add	r0, pc
    3682:	e9cd 1000 	strd	r1, r0, [sp]
    3686:	480a      	ldr	r0, [pc, #40]	@ (36b0 <get_ip_port@@Base+0xc78>)
    3688:	490a      	ldr	r1, [pc, #40]	@ (36b4 <get_ip_port@@Base+0xc7c>)
    368a:	4478      	add	r0, pc
    368c:	4a0a      	ldr	r2, [pc, #40]	@ (36b8 <get_ip_port@@Base+0xc80>)
    368e:	4b0b      	ldr	r3, [pc, #44]	@ (36bc <get_ip_port@@Base+0xc84>)
    3690:	4479      	add	r1, pc
    3692:	6800      	ldr	r0, [r0, #0]
    3694:	447a      	add	r2, pc
    3696:	447b      	add	r3, pc
    3698:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    369c:	4620      	mov	r0, r4
    369e:	f7fd ef5c 	blx	1558 <fprintf@plt>
    36a2:	4620      	mov	r0, r4
    36a4:	f7fd ef5e 	blx	1564 <fflush@plt>
    36a8:	f7fd ef62 	blx	1570 <abort@plt>
    36ac:	138b      	asrs	r3, r1, #14
    36ae:	0000      	movs	r0, r0
    36b0:	388a      	subs	r0, #138	@ 0x8a
    36b2:	0000      	movs	r0, r0
    36b4:	10fb      	asrs	r3, r7, #3
    36b6:	0000      	movs	r0, r0
    36b8:	1390      	asrs	r0, r2, #14
    36ba:	0000      	movs	r0, r0
    36bc:	12ff      	asrs	r7, r7, #11
    36be:	0000      	movs	r0, r0
    36c0:	b5bc      	push	{r2, r3, r4, r5, r7, lr}
    36c2:	af04      	add	r7, sp, #16
    36c4:	4605      	mov	r5, r0
    36c6:	f021 000f 	bic.w	r0, r1, #15
    36ca:	460c      	mov	r4, r1
    36cc:	f5b0 7f88 	cmp.w	r0, #272	@ 0x110
    36d0:	d010      	beq.n	36f4 <get_ip_port@@Base+0xcbc>
    36d2:	f5b0 7f80 	cmp.w	r0, #256	@ 0x100
    36d6:	d126      	bne.n	3726 <get_ip_port@@Base+0xcee>
    36d8:	f895 0041 	ldrb.w	r0, [r5, #65]	@ 0x41
    36dc:	b9d8      	cbnz	r0, 3716 <get_ip_port@@Base+0xcde>
    36de:	2001      	movs	r0, #1
    36e0:	f885 0041 	strb.w	r0, [r5, #65]	@ 0x41
    36e4:	f105 0048 	add.w	r0, r5, #72	@ 0x48
    36e8:	f895 1040 	ldrb.w	r1, [r5, #64]	@ 0x40
    36ec:	b189      	cbz	r1, 3712 <get_ip_port@@Base+0xcda>
    36ee:	f7ff ede8 	blx	32c0 <get_ip_port@@Base+0x888>
    36f2:	e010      	b.n	3716 <get_ip_port@@Base+0xcde>
    36f4:	f895 0042 	ldrb.w	r0, [r5, #66]	@ 0x42
    36f8:	b930      	cbnz	r0, 3708 <get_ip_port@@Base+0xcd0>
    36fa:	2001      	movs	r0, #1
    36fc:	f885 0042 	strb.w	r0, [r5, #66]	@ 0x42
    3700:	f105 00d0 	add.w	r0, r5, #208	@ 0xd0
    3704:	f7ff ede0 	blx	32c8 <get_ip_port@@Base+0x890>
    3708:	eb05 00c4 	add.w	r0, r5, r4, lsl #3
    370c:	f5a0 60f6 	sub.w	r0, r0, #1968	@ 0x7b0
    3710:	e005      	b.n	371e <get_ip_port@@Base+0xce6>
    3712:	f7ff edd2 	blx	32b8 <get_ip_port@@Base+0x880>
    3716:	eb05 00c4 	add.w	r0, r5, r4, lsl #3
    371a:	f5a0 60f7 	sub.w	r0, r0, #1976	@ 0x7b8
    371e:	e9d0 0100 	ldrd	r0, r1, [r0]
    3722:	b002      	add	sp, #8
    3724:	bdb0      	pop	{r4, r5, r7, pc}
    3726:	480c      	ldr	r0, [pc, #48]	@ (3758 <get_ip_port@@Base+0xd20>)
    3728:	f240 61d2 	movw	r1, #1746	@ 0x6d2
    372c:	4478      	add	r0, pc
    372e:	e9cd 1000 	strd	r1, r0, [sp]
    3732:	480a      	ldr	r0, [pc, #40]	@ (375c <get_ip_port@@Base+0xd24>)
    3734:	490a      	ldr	r1, [pc, #40]	@ (3760 <get_ip_port@@Base+0xd28>)
    3736:	4478      	add	r0, pc
    3738:	4a0a      	ldr	r2, [pc, #40]	@ (3764 <get_ip_port@@Base+0xd2c>)
    373a:	4b0b      	ldr	r3, [pc, #44]	@ (3768 <get_ip_port@@Base+0xd30>)
    373c:	4479      	add	r1, pc
    373e:	6800      	ldr	r0, [r0, #0]
    3740:	447a      	add	r2, pc
    3742:	447b      	add	r3, pc
    3744:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    3748:	4620      	mov	r0, r4
    374a:	f7fd ef06 	blx	1558 <fprintf@plt>
    374e:	4620      	mov	r0, r4
    3750:	f7fd ef08 	blx	1564 <fflush@plt>
    3754:	f7fd ef0c 	blx	1570 <abort@plt>
    3758:	1315      	asrs	r5, r2, #12
    375a:	0000      	movs	r0, r0
    375c:	37de      	adds	r7, #222	@ 0xde
    375e:	0000      	movs	r0, r0
    3760:	104f      	asrs	r7, r1, #1
    3762:	0000      	movs	r0, r0
    3764:	12f0      	asrs	r0, r6, #11
    3766:	0000      	movs	r0, r0
    3768:	1253      	asrs	r3, r2, #9
    376a:	0000      	movs	r0, r0
    376c:	b5f0      	push	{r4, r5, r6, r7, lr}
    376e:	af03      	add	r7, sp, #12
    3770:	f84d 8d04 	str.w	r8, [sp, #-4]!
    3774:	b082      	sub	sp, #8
    3776:	4604      	mov	r4, r0
    3778:	f021 000f 	bic.w	r0, r1, #15
    377c:	4698      	mov	r8, r3
    377e:	4615      	mov	r5, r2
    3780:	460e      	mov	r6, r1
    3782:	f5b0 7f88 	cmp.w	r0, #272	@ 0x110
    3786:	d010      	beq.n	37aa <get_ip_port@@Base+0xd72>
    3788:	f5b0 7f80 	cmp.w	r0, #256	@ 0x100
    378c:	d128      	bne.n	37e0 <get_ip_port@@Base+0xda8>
    378e:	f894 0041 	ldrb.w	r0, [r4, #65]	@ 0x41
    3792:	b9d8      	cbnz	r0, 37cc <get_ip_port@@Base+0xd94>
    3794:	2001      	movs	r0, #1
    3796:	f884 0041 	strb.w	r0, [r4, #65]	@ 0x41
    379a:	f104 0048 	add.w	r0, r4, #72	@ 0x48
    379e:	f894 1040 	ldrb.w	r1, [r4, #64]	@ 0x40
    37a2:	b189      	cbz	r1, 37c8 <get_ip_port@@Base+0xd90>
    37a4:	f7ff ed8c 	blx	32c0 <get_ip_port@@Base+0x888>
    37a8:	e010      	b.n	37cc <get_ip_port@@Base+0xd94>
    37aa:	f894 0042 	ldrb.w	r0, [r4, #66]	@ 0x42
    37ae:	b930      	cbnz	r0, 37be <get_ip_port@@Base+0xd86>
    37b0:	2001      	movs	r0, #1
    37b2:	f884 0042 	strb.w	r0, [r4, #66]	@ 0x42
    37b6:	f104 00d0 	add.w	r0, r4, #208	@ 0xd0
    37ba:	f7ff ed86 	blx	32c8 <get_ip_port@@Base+0x890>
    37be:	eb04 00c6 	add.w	r0, r4, r6, lsl #3
    37c2:	f5a0 60f6 	sub.w	r0, r0, #1968	@ 0x7b0
    37c6:	e005      	b.n	37d4 <get_ip_port@@Base+0xd9c>
    37c8:	f7ff ed76 	blx	32b8 <get_ip_port@@Base+0x880>
    37cc:	eb04 00c6 	add.w	r0, r4, r6, lsl #3
    37d0:	f5a0 60f7 	sub.w	r0, r0, #1976	@ 0x7b8
    37d4:	e9c0 5800 	strd	r5, r8, [r0]
    37d8:	b002      	add	sp, #8
    37da:	f85d 8b04 	ldr.w	r8, [sp], #4
    37de:	bdf0      	pop	{r4, r5, r6, r7, pc}
    37e0:	480c      	ldr	r0, [pc, #48]	@ (3814 <get_ip_port@@Base+0xddc>)
    37e2:	f240 61f6 	movw	r1, #1782	@ 0x6f6
    37e6:	4478      	add	r0, pc
    37e8:	e9cd 1000 	strd	r1, r0, [sp]
    37ec:	480a      	ldr	r0, [pc, #40]	@ (3818 <get_ip_port@@Base+0xde0>)
    37ee:	490b      	ldr	r1, [pc, #44]	@ (381c <get_ip_port@@Base+0xde4>)
    37f0:	4478      	add	r0, pc
    37f2:	4a0b      	ldr	r2, [pc, #44]	@ (3820 <get_ip_port@@Base+0xde8>)
    37f4:	4b0b      	ldr	r3, [pc, #44]	@ (3824 <get_ip_port@@Base+0xdec>)
    37f6:	4479      	add	r1, pc
    37f8:	6800      	ldr	r0, [r0, #0]
    37fa:	447a      	add	r2, pc
    37fc:	447b      	add	r3, pc
    37fe:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    3802:	4620      	mov	r0, r4
    3804:	f7fd eea8 	blx	1558 <fprintf@plt>
    3808:	4620      	mov	r0, r4
    380a:	f7fd eeac 	blx	1564 <fflush@plt>
    380e:	f7fd eeb0 	blx	1570 <abort@plt>
    3812:	bf00      	nop
    3814:	125b      	asrs	r3, r3, #9
    3816:	0000      	movs	r0, r0
    3818:	3724      	adds	r7, #36	@ 0x24
    381a:	0000      	movs	r0, r0
    381c:	0f95      	lsrs	r5, r2, #30
    381e:	0000      	movs	r0, r0
    3820:	1262      	asrs	r2, r4, #9
    3822:	0000      	movs	r0, r0
    3824:	1199      	asrs	r1, r3, #6
    3826:	0000      	movs	r0, r0
    3828:	b5bf      	push	{r0, r1, r2, r3, r4, r5, r7, lr}
    382a:	af06      	add	r7, sp, #24
    382c:	4604      	mov	r4, r0
    382e:	4810      	ldr	r0, [pc, #64]	@ (3870 <get_ip_port@@Base+0xe38>)
    3830:	a901      	add	r1, sp, #4
    3832:	aa02      	add	r2, sp, #8
    3834:	4478      	add	r0, pc
    3836:	6805      	ldr	r5, [r0, #0]
    3838:	6828      	ldr	r0, [r5, #0]
    383a:	9003      	str	r0, [sp, #12]
    383c:	2000      	movs	r0, #0
    383e:	e9cd 0001 	strd	r0, r0, [sp, #4]
    3842:	f8d4 0178 	ldr.w	r0, [r4, #376]	@ 0x178
    3846:	f7ff f903 	bl	2a50 <get_ip_port@@Base+0x18>
    384a:	e9dd 2301 	ldrd	r2, r3, [sp, #4]
    384e:	4601      	mov	r1, r0
    3850:	4620      	mov	r0, r4
    3852:	f7ff f921 	bl	2a98 <get_ip_port@@Base+0x60>
    3856:	6829      	ldr	r1, [r5, #0]
    3858:	9a03      	ldr	r2, [sp, #12]
    385a:	1a89      	subs	r1, r1, r2
    385c:	bf01      	itttt	eq
    385e:	3808      	subeq	r0, #8
    3860:	fab0 f080 	clzeq	r0, r0
    3864:	0940      	lsreq	r0, r0, #5
    3866:	b004      	addeq	sp, #16
    3868:	bf08      	it	eq
    386a:	bdb0      	popeq	{r4, r5, r7, pc}
    386c:	f7fd eda2 	blx	13b4 <__stack_chk_fail@plt>
    3870:	369c      	adds	r6, #156	@ 0x9c
    3872:	0000      	movs	r0, r0
    3874:	b5d0      	push	{r4, r6, r7, lr}
    3876:	af02      	add	r7, sp, #8
    3878:	4604      	mov	r4, r0
    387a:	f000 f805 	bl	3888 <get_ip_port@@Base+0xe50>
    387e:	4620      	mov	r0, r4
    3880:	e8bd 40d0 	ldmia.w	sp!, {r4, r6, r7, lr}
    3884:	f000 bc50 	b.w	4128 <get_ip_port@@Base+0x16f0>
    3888:	b5d0      	push	{r4, r6, r7, lr}
    388a:	af02      	add	r7, sp, #8
    388c:	4604      	mov	r4, r0
    388e:	f890 0041 	ldrb.w	r0, [r0, #65]	@ 0x41
    3892:	b148      	cbz	r0, 38a8 <get_ip_port@@Base+0xe70>
    3894:	f894 1040 	ldrb.w	r1, [r4, #64]	@ 0x40
    3898:	f104 0048 	add.w	r0, r4, #72	@ 0x48
    389c:	b111      	cbz	r1, 38a4 <get_ip_port@@Base+0xe6c>
    389e:	f000 eba6 	blx	3fec <get_ip_port@@Base+0x15b4>
    38a2:	e001      	b.n	38a8 <get_ip_port@@Base+0xe70>
    38a4:	f000 eb9e 	blx	3fe4 <get_ip_port@@Base+0x15ac>
    38a8:	f894 0042 	ldrb.w	r0, [r4, #66]	@ 0x42
    38ac:	b128      	cbz	r0, 38ba <get_ip_port@@Base+0xe82>
    38ae:	f104 00d0 	add.w	r0, r4, #208	@ 0xd0
    38b2:	e8bd 40d0 	ldmia.w	sp!, {r4, r6, r7, lr}
    38b6:	f000 bc3f 	b.w	4138 <get_ip_port@@Base+0x1700>
    38ba:	bdd0      	pop	{r4, r6, r7, pc}
    38bc:	b5f0      	push	{r4, r5, r6, r7, lr}
    38be:	af03      	add	r7, sp, #12
    38c0:	e92d 0bfc 	stmdb	sp!, {r2, r3, r4, r5, r6, r7, r8, r9, fp}
    38c4:	4813      	ldr	r0, [pc, #76]	@ (3914 <get_ip_port@@Base+0xedc>)
    38c6:	460c      	mov	r4, r1
    38c8:	a901      	add	r1, sp, #4
    38ca:	4698      	mov	r8, r3
    38cc:	4478      	add	r0, pc
    38ce:	4616      	mov	r6, r2
    38d0:	6805      	ldr	r5, [r0, #0]
    38d2:	6828      	ldr	r0, [r5, #0]
    38d4:	9005      	str	r0, [sp, #20]
    38d6:	4620      	mov	r0, r4
    38d8:	f7fd ee50 	blx	157c <dladdr@plt>
    38dc:	b178      	cbz	r0, 38fe <get_ip_port@@Base+0xec6>
    38de:	9b03      	ldr	r3, [sp, #12]
    38e0:	b16b      	cbz	r3, 38fe <get_ip_port@@Base+0xec6>
    38e2:	4a0d      	ldr	r2, [pc, #52]	@ (3918 <get_ip_port@@Base+0xee0>)
    38e4:	4630      	mov	r0, r6
    38e6:	4641      	mov	r1, r8
    38e8:	f8d7 9008 	ldr.w	r9, [r7, #8]
    38ec:	447a      	add	r2, pc
    38ee:	f7fd ee4c 	blx	1588 <snprintf@plt>
    38f2:	9804      	ldr	r0, [sp, #16]
    38f4:	1a20      	subs	r0, r4, r0
    38f6:	f8c9 0000 	str.w	r0, [r9]
    38fa:	2001      	movs	r0, #1
    38fc:	e000      	b.n	3900 <get_ip_port@@Base+0xec8>
    38fe:	2000      	movs	r0, #0
    3900:	6829      	ldr	r1, [r5, #0]
    3902:	9a05      	ldr	r2, [sp, #20]
    3904:	1a89      	subs	r1, r1, r2
    3906:	bf02      	ittt	eq
    3908:	b006      	addeq	sp, #24
    390a:	e8bd 0b00 	ldmiaeq.w	sp!, {r8, r9, fp}
    390e:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    3910:	f7fd ed50 	blx	13b4 <__stack_chk_fail@plt>
    3914:	3604      	adds	r6, #4
    3916:	0000      	movs	r0, r0
    3918:	1181      	asrs	r1, r0, #6
    391a:	0000      	movs	r0, r0
    391c:	b5bc      	push	{r2, r3, r4, r5, r7, lr}
    391e:	af04      	add	r7, sp, #16
    3920:	4608      	mov	r0, r1
    3922:	490e      	ldr	r1, [pc, #56]	@ (395c <get_ip_port@@Base+0xf24>)
    3924:	4614      	mov	r4, r2
    3926:	4479      	add	r1, pc
    3928:	680d      	ldr	r5, [r1, #0]
    392a:	6829      	ldr	r1, [r5, #0]
    392c:	9101      	str	r1, [sp, #4]
    392e:	2100      	movs	r1, #0
    3930:	9100      	str	r1, [sp, #0]
    3932:	4669      	mov	r1, sp
    3934:	f7fd ee2e 	blx	1594 <__gnu_Unwind_Find_exidx@plt>
    3938:	9900      	ldr	r1, [sp, #0]
    393a:	2800      	cmp	r0, #0
    393c:	e9c4 0100 	strd	r0, r1, [r4]
    3940:	bf18      	it	ne
    3942:	2001      	movne	r0, #1
    3944:	2900      	cmp	r1, #0
    3946:	bf18      	it	ne
    3948:	2101      	movne	r1, #1
    394a:	682a      	ldr	r2, [r5, #0]
    394c:	9b01      	ldr	r3, [sp, #4]
    394e:	1ad2      	subs	r2, r2, r3
    3950:	bf02      	ittt	eq
    3952:	4008      	andeq	r0, r1
    3954:	b002      	addeq	sp, #8
    3956:	bdb0      	popeq	{r4, r5, r7, pc}
    3958:	f7fd ed2c 	blx	13b4 <__stack_chk_fail@plt>
    395c:	35aa      	adds	r5, #170	@ 0xaa
    395e:	0000      	movs	r0, r0
    3960:	b5f0      	push	{r4, r5, r6, r7, lr}
    3962:	af03      	add	r7, sp, #12
    3964:	e92d 0f00 	stmdb	sp!, {r8, r9, sl, fp}
    3968:	b089      	sub	sp, #36	@ 0x24
    396a:	9107      	str	r1, [sp, #28]
    396c:	4604      	mov	r4, r0
    396e:	485c      	ldr	r0, [pc, #368]	@ (3ae0 <get_ip_port@@Base+0x10a8>)
    3970:	4613      	mov	r3, r2
    3972:	2100      	movs	r1, #0
    3974:	2500      	movs	r5, #0
    3976:	4478      	add	r0, pc
    3978:	f8d0 a000 	ldr.w	sl, [r0]
    397c:	f8da 0000 	ldr.w	r0, [sl]
    3980:	9008      	str	r0, [sp, #32]
    3982:	a807      	add	r0, sp, #28
    3984:	6856      	ldr	r6, [r2, #4]
    3986:	6862      	ldr	r2, [r4, #4]
    3988:	e9cd 6200 	strd	r6, r2, [sp]
    398c:	e9cd 3002 	strd	r3, r0, [sp, #8]
    3990:	a804      	add	r0, sp, #16
    3992:	f000 f8b9 	bl	3b08 <get_ip_port@@Base+0x10d0>
    3996:	9804      	ldr	r0, [sp, #16]
    3998:	2800      	cmp	r0, #0
    399a:	d076      	beq.n	3a8a <get_ip_port@@Base+0x1052>
    399c:	42b0      	cmp	r0, r6
    399e:	d074      	beq.n	3a8a <get_ip_port@@Base+0x1052>
    39a0:	9906      	ldr	r1, [sp, #24]
    39a2:	6809      	ldr	r1, [r1, #0]
    39a4:	eb01 01c0 	add.w	r1, r1, r0, lsl #3
    39a8:	4608      	mov	r0, r1
    39aa:	f850 2904 	ldr.w	r2, [r0], #-4
    39ae:	b110      	cbz	r0, 39b6 <get_ip_port@@Base+0xf7e>
    39b0:	6803      	ldr	r3, [r0, #0]
    39b2:	2b01      	cmp	r3, #1
    39b4:	d101      	bne.n	39ba <get_ip_port@@Base+0xf82>
    39b6:	2500      	movs	r5, #0
    39b8:	e067      	b.n	3a8a <get_ip_port@@Base+0x1052>
    39ba:	4689      	mov	r9, r1
    39bc:	2b00      	cmp	r3, #0
    39be:	f859 8d08 	ldr.w	r8, [r9, #-8]!
    39c2:	d418      	bmi.n	39f6 <get_ip_port@@Base+0xfbe>
    39c4:	f003 4580 	and.w	r5, r3, #1073741824	@ 0x40000000
    39c8:	ea43 0545 	orr.w	r5, r3, r5, lsl #1
    39cc:	582b      	ldr	r3, [r5, r0]
    39ce:	4428      	add	r0, r5
    39d0:	f1b3 3fff 	cmp.w	r3, #4294967295	@ 0xffffffff
    39d4:	dd12      	ble.n	39fc <get_ip_port@@Base+0xfc4>
    39d6:	f003 4580 	and.w	r5, r3, #1073741824	@ 0x40000000
    39da:	f04f 0c00 	mov.w	ip, #0
    39de:	ea43 0345 	orr.w	r3, r3, r5, lsl #1
    39e2:	eb03 0e00 	add.w	lr, r3, r0
    39e6:	4603      	mov	r3, r0
    39e8:	f853 5f04 	ldr.w	r5, [r3, #4]!
    39ec:	0e2d      	lsrs	r5, r5, #24
    39ee:	eb03 0385 	add.w	r3, r3, r5, lsl #2
    39f2:	3304      	adds	r3, #4
    39f4:	e015      	b.n	3a22 <get_ip_port@@Base+0xfea>
    39f6:	f04f 0c01 	mov.w	ip, #1
    39fa:	e001      	b.n	3a00 <get_ip_port@@Base+0xfc8>
    39fc:	f04f 0c00 	mov.w	ip, #0
    3a00:	f3c3 6503 	ubfx	r5, r3, #24, #4
    3a04:	2d02      	cmp	r5, #2
    3a06:	d014      	beq.n	3a32 <get_ip_port@@Base+0xffa>
    3a08:	2d01      	cmp	r5, #1
    3a0a:	d00c      	beq.n	3a26 <get_ip_port@@Base+0xfee>
    3a0c:	2d00      	cmp	r5, #0
    3a0e:	d148      	bne.n	3aa2 <get_ip_port@@Base+0x106a>
    3a10:	1d03      	adds	r3, r0, #4
    3a12:	f1bc 0f00 	cmp.w	ip, #0
    3a16:	bf18      	it	ne
    3a18:	2300      	movne	r3, #0
    3a1a:	4d33      	ldr	r5, [pc, #204]	@ (3ae8 <get_ip_port@@Base+0x10b0>)
    3a1c:	447d      	add	r5, pc
    3a1e:	f8d5 e000 	ldr.w	lr, [r5]
    3a22:	2500      	movs	r5, #0
    3a24:	e017      	b.n	3a56 <get_ip_port@@Base+0x101e>
    3a26:	4d2f      	ldr	r5, [pc, #188]	@ (3ae4 <get_ip_port@@Base+0x10ac>)
    3a28:	447d      	add	r5, pc
    3a2a:	f8d5 e000 	ldr.w	lr, [r5]
    3a2e:	2500      	movs	r5, #0
    3a30:	e004      	b.n	3a3c <get_ip_port@@Base+0x1004>
    3a32:	4d33      	ldr	r5, [pc, #204]	@ (3b00 <get_ip_port@@Base+0x10c8>)
    3a34:	447d      	add	r5, pc
    3a36:	f8d5 e000 	ldr.w	lr, [r5]
    3a3a:	2501      	movs	r5, #1
    3a3c:	f3c3 4307 	ubfx	r3, r3, #16, #8
    3a40:	f08c 0b01 	eor.w	fp, ip, #1
    3a44:	fab3 f683 	clz	r6, r3
    3a48:	0976      	lsrs	r6, r6, #5
    3a4a:	ea56 060b 	orrs.w	r6, r6, fp
    3a4e:	d02d      	beq.n	3aac <get_ip_port@@Base+0x1074>
    3a50:	eb00 0383 	add.w	r3, r0, r3, lsl #2
    3a54:	3304      	adds	r3, #4
    3a56:	f002 4680 	and.w	r6, r2, #1073741824	@ 0x40000000
    3a5a:	f8c4 0178 	str.w	r0, [r4, #376]	@ 0x178
    3a5e:	2d00      	cmp	r5, #0
    3a60:	ea42 0246 	orr.w	r2, r2, r6, lsl #1
    3a64:	4411      	add	r1, r2
    3a66:	f008 4280 	and.w	r2, r8, #1073741824	@ 0x40000000
    3a6a:	ea48 0242 	orr.w	r2, r8, r2, lsl #1
    3a6e:	444a      	add	r2, r9
    3a70:	e9c4 2156 	strd	r2, r1, [r4, #344]	@ 0x158
    3a74:	e9c4 3e58 	strd	r3, lr, [r4, #352]	@ 0x160
    3a78:	bf18      	it	ne
    3a7a:	2502      	movne	r5, #2
    3a7c:	f1bc 0f00 	cmp.w	ip, #0
    3a80:	bf18      	it	ne
    3a82:	2501      	movne	r5, #1
    3a84:	f8c4 516c 	str.w	r5, [r4, #364]	@ 0x16c
    3a88:	2501      	movs	r5, #1
    3a8a:	f8da 0000 	ldr.w	r0, [sl]
    3a8e:	9908      	ldr	r1, [sp, #32]
    3a90:	1a40      	subs	r0, r0, r1
    3a92:	bf01      	itttt	eq
    3a94:	4628      	moveq	r0, r5
    3a96:	b009      	addeq	sp, #36	@ 0x24
    3a98:	e8bd 0f00 	ldmiaeq.w	sp!, {r8, r9, sl, fp}
    3a9c:	bdf0      	popeq	{r4, r5, r6, r7, pc}
    3a9e:	f7fd ec8a 	blx	13b4 <__stack_chk_fail@plt>
    3aa2:	4812      	ldr	r0, [pc, #72]	@ (3aec <get_ip_port@@Base+0x10b4>)
    3aa4:	f240 312e 	movw	r1, #814	@ 0x32e
    3aa8:	4478      	add	r0, pc
    3aaa:	e003      	b.n	3ab4 <get_ip_port@@Base+0x107c>
    3aac:	4815      	ldr	r0, [pc, #84]	@ (3b04 <get_ip_port@@Base+0x10cc>)
    3aae:	f240 3135 	movw	r1, #821	@ 0x335
    3ab2:	4478      	add	r0, pc
    3ab4:	e9cd 1000 	strd	r1, r0, [sp]
    3ab8:	480d      	ldr	r0, [pc, #52]	@ (3af0 <get_ip_port@@Base+0x10b8>)
    3aba:	490e      	ldr	r1, [pc, #56]	@ (3af4 <get_ip_port@@Base+0x10bc>)
    3abc:	4478      	add	r0, pc
    3abe:	4a0e      	ldr	r2, [pc, #56]	@ (3af8 <get_ip_port@@Base+0x10c0>)
    3ac0:	4b0e      	ldr	r3, [pc, #56]	@ (3afc <get_ip_port@@Base+0x10c4>)
    3ac2:	4479      	add	r1, pc
    3ac4:	6800      	ldr	r0, [r0, #0]
    3ac6:	447a      	add	r2, pc
    3ac8:	447b      	add	r3, pc
    3aca:	f100 04a8 	add.w	r4, r0, #168	@ 0xa8
    3ace:	4620      	mov	r0, r4
    3ad0:	f7fd ed42 	blx	1558 <fprintf@plt>
    3ad4:	4620      	mov	r0, r4
    3ad6:	f7fd ed46 	blx	1564 <fflush@plt>
    3ada:	f7fd ed4a 	blx	1570 <abort@plt>
    3ade:	bf00      	nop
    3ae0:	355a      	adds	r5, #90	@ 0x5a
    3ae2:	0000      	movs	r0, r0
    3ae4:	34f0      	adds	r4, #240	@ 0xf0
    3ae6:	0000      	movs	r0, r0
    3ae8:	3500      	adds	r5, #0
    3aea:	0000      	movs	r0, r0
    3aec:	0fe0      	lsrs	r0, r4, #31
    3aee:	0000      	movs	r0, r0
    3af0:	3458      	adds	r4, #88	@ 0x58
    3af2:	0000      	movs	r0, r0
    3af4:	0cc9      	lsrs	r1, r1, #19
    3af6:	0000      	movs	r0, r0
    3af8:	0faa      	lsrs	r2, r5, #30
    3afa:	0000      	movs	r0, r0
    3afc:	0e48      	lsrs	r0, r1, #25
    3afe:	0000      	movs	r0, r0
    3b00:	34ec      	adds	r4, #236	@ 0xec
    3b02:	0000      	movs	r0, r0
    3b04:	0ff2      	lsrs	r2, r6, #31
    3b06:	0000      	movs	r0, r0
    3b08:	b5b0      	push	{r4, r5, r7, lr}
    3b0a:	af02      	add	r7, sp, #8
    3b0c:	b088      	sub	sp, #32
    3b0e:	4c0c      	ldr	r4, [pc, #48]	@ (3b40 <get_ip_port@@Base+0x1108>)
    3b10:	447c      	add	r4, pc
    3b12:	6824      	ldr	r4, [r4, #0]
    3b14:	6825      	ldr	r5, [r4, #0]
    3b16:	9507      	str	r5, [sp, #28]
    3b18:	ad06      	add	r5, sp, #24
    3b1a:	9504      	str	r5, [sp, #16]
    3b1c:	697d      	ldr	r5, [r7, #20]
    3b1e:	9503      	str	r5, [sp, #12]
    3b20:	693d      	ldr	r5, [r7, #16]
    3b22:	9502      	str	r5, [sp, #8]
    3b24:	68fd      	ldr	r5, [r7, #12]
    3b26:	9501      	str	r5, [sp, #4]
    3b28:	68bd      	ldr	r5, [r7, #8]
    3b2a:	9500      	str	r5, [sp, #0]
    3b2c:	f000 f80a 	bl	3b44 <get_ip_port@@Base+0x110c>
    3b30:	6820      	ldr	r0, [r4, #0]
    3b32:	9907      	ldr	r1, [sp, #28]
    3b34:	1a40      	subs	r0, r0, r1
    3b36:	bf04      	itt	eq
    3b38:	b008      	addeq	sp, #32
    3b3a:	bdb0      	popeq	{r4, r5, r7, pc}
    3b3c:	f7fd ec3a 	blx	13b4 <__stack_chk_fail@plt>
    3b40:	33c0      	adds	r3, #192	@ 0xc0
    3b42:	0000      	movs	r0, r0
    3b44:	b5f0      	push	{r4, r5, r6, r7, lr}
    3b46:	af03      	add	r7, sp, #12
    3b48:	f84d 8d04 	str.w	r8, [sp, #-4]!
    3b4c:	68bc      	ldr	r4, [r7, #8]
    3b4e:	1a65      	subs	r5, r4, r1
    3b50:	697c      	ldr	r4, [r7, #20]
    3b52:	f8d4 c000 	ldr.w	ip, [r4]
    3b56:	b1ad      	cbz	r5, 3b84 <get_ip_port@@Base+0x114c>
    3b58:	f8d3 e000 	ldr.w	lr, [r3]
    3b5c:	eb01 0455 	add.w	r4, r1, r5, lsr #1
    3b60:	462e      	mov	r6, r5
    3b62:	f85e 8034 	ldr.w	r8, [lr, r4, lsl #3]
    3b66:	f008 4580 	and.w	r5, r8, #1073741824	@ 0x40000000
    3b6a:	ea48 0845 	orr.w	r8, r8, r5, lsl #1
    3b6e:	eb0e 05c4 	add.w	r5, lr, r4, lsl #3
    3b72:	eb08 0e05 	add.w	lr, r8, r5
    3b76:	0875      	lsrs	r5, r6, #1
    3b78:	45f4      	cmp	ip, lr
    3b7a:	d3ec      	bcc.n	3b56 <get_ip_port@@Base+0x111e>
    3b7c:	43e9      	mvns	r1, r5
    3b7e:	1875      	adds	r5, r6, r1
    3b80:	1c61      	adds	r1, r4, #1
    3b82:	e7e8      	b.n	3b56 <get_ip_port@@Base+0x111e>
    3b84:	c00e      	stmia	r0!, {r1, r2, r3}
    3b86:	f85d 8b04 	ldr.w	r8, [sp], #4
    3b8a:	bdf0      	pop	{r4, r5, r6, r7, pc}
    3b8c:	1c8a      	adds	r2, r1, #2
    3b8e:	2a61      	cmp	r2, #97	@ 0x61
    3b90:	f200 8069 	bhi.w	3c66 <get_ip_port@@Base+0x122e>
    3b94:	48b7      	ldr	r0, [pc, #732]	@ (3e74 <get_ip_port@@Base+0x143c>)
    3b96:	4478      	add	r0, pc
    3b98:	e8df f012 	tbh	[pc, r2, lsl #1]
    3b9c:	0062      	lsls	r2, r4, #1
    3b9e:	0090      	lsls	r0, r2, #2
    3ba0:	0091      	lsls	r1, r2, #2
    3ba2:	0094      	lsls	r4, r2, #2
    3ba4:	0097      	lsls	r7, r2, #2
    3ba6:	009a      	lsls	r2, r3, #2
    3ba8:	009d      	lsls	r5, r3, #2
    3baa:	00a0      	lsls	r0, r4, #2
    3bac:	00a3      	lsls	r3, r4, #2
    3bae:	00a6      	lsls	r6, r4, #2
    3bb0:	00a9      	lsls	r1, r5, #2
    3bb2:	00ac      	lsls	r4, r5, #2
    3bb4:	00af      	lsls	r7, r5, #2
    3bb6:	00b2      	lsls	r2, r6, #2
    3bb8:	00b5      	lsls	r5, r6, #2
    3bba:	0062      	lsls	r2, r4, #1
    3bbc:	00b8      	lsls	r0, r7, #2
    3bbe:	0090      	lsls	r0, r2, #2
    3bc0:	008e      	lsls	r6, r1, #2
    3bc2:	008e      	lsls	r6, r1, #2
    3bc4:	008e      	lsls	r6, r1, #2
    3bc6:	008e      	lsls	r6, r1, #2
    3bc8:	008e      	lsls	r6, r1, #2
    3bca:	008e      	lsls	r6, r1, #2
    3bcc:	008e      	lsls	r6, r1, #2
    3bce:	008e      	lsls	r6, r1, #2
    3bd0:	008e      	lsls	r6, r1, #2
    3bd2:	008e      	lsls	r6, r1, #2
    3bd4:	008e      	lsls	r6, r1, #2
    3bd6:	008e      	lsls	r6, r1, #2
    3bd8:	008e      	lsls	r6, r1, #2
    3bda:	008e      	lsls	r6, r1, #2
    3bdc:	008e      	lsls	r6, r1, #2
    3bde:	008e      	lsls	r6, r1, #2
    3be0:	008e      	lsls	r6, r1, #2
    3be2:	008e      	lsls	r6, r1, #2
    3be4:	008e      	lsls	r6, r1, #2
    3be6:	008e      	lsls	r6, r1, #2
    3be8:	008e      	lsls	r6, r1, #2
    3bea:	008e      	lsls	r6, r1, #2
    3bec:	008e      	lsls	r6, r1, #2
    3bee:	008e      	lsls	r6, r1, #2
    3bf0:	008e      	lsls	r6, r1, #2
    3bf2:	008e      	lsls	r6, r1, #2
    3bf4:	008e      	lsls	r6, r1, #2
    3bf6:	008e      	lsls	r6, r1, #2
    3bf8:	008e      	lsls	r6, r1, #2
    3bfa:	008e      	lsls	r6, r1, #2
    3bfc:	008e      	lsls	r6, r1, #2
    3bfe:	008e      	lsls	r6, r1, #2
    3c00:	008e      	lsls	r6, r1, #2
    3c02:	008e      	lsls	r6, r1, #2
    3c04:	008e      	lsls	r6, r1, #2
    3c06:	008e      	lsls	r6, r1, #2
    3c08:	008e      	lsls	r6, r1, #2
    3c0a:	008e      	lsls	r6, r1, #2
    3c0c:	008e      	lsls	r6, r1, #2
    3c0e:	008e      	lsls	r6, r1, #2
    3c10:	008e      	lsls	r6, r1, #2
    3c12:	008e      	lsls	r6, r1, #2
    3c14:	008e      	lsls	r6, r1, #2
    3c16:	008e      	lsls	r6, r1, #2
    3c18:	008e      	lsls	r6, r1, #2
    3c1a:	008e      	lsls	r6, r1, #2
    3c1c:	008e      	lsls	r6, r1, #2
    3c1e:	008e      	lsls	r6, r1, #2
    3c20:	00bb      	lsls	r3, r7, #2
    3c22:	00be      	lsls	r6, r7, #2
    3c24:	00c1      	lsls	r1, r0, #3
    3c26:	00c4      	lsls	r4, r0, #3
    3c28:	00c7      	lsls	r7, r0, #3
    3c2a:	00ca      	lsls	r2, r1, #3
    3c2c:	00cd      	lsls	r5, r1, #3
    3c2e:	00d0      	lsls	r0, r2, #3
    3c30:	00d3      	lsls	r3, r2, #3
    3c32:	00d6      	lsls	r6, r2, #3
    3c34:	00d9      	lsls	r1, r3, #3
    3c36:	00dc      	lsls	r4, r3, #3
    3c38:	00df      	lsls	r7, r3, #3
    3c3a:	00e2      	lsls	r2, r4, #3
    3c3c:	00e5      	lsls	r5, r4, #3
    3c3e:	00e8      	lsls	r0, r5, #3
    3c40:	00eb      	lsls	r3, r5, #3
    3c42:	00ee      	lsls	r6, r5, #3
    3c44:	00f1      	lsls	r1, r6, #3
    3c46:	00f4      	lsls	r4, r6, #3
    3c48:	00f7      	lsls	r7, r6, #3
    3c4a:	00fa      	lsls	r2, r7, #3
    3c4c:	00fd      	lsls	r5, r7, #3
    3c4e:	0100      	lsls	r0, r0, #4
    3c50:	0103      	lsls	r3, r0, #4
    3c52:	0106      	lsls	r6, r0, #4
    3c54:	0109      	lsls	r1, r1, #4
    3c56:	010c      	lsls	r4, r1, #4
    3c58:	010f      	lsls	r7, r1, #4
    3c5a:	0112      	lsls	r2, r2, #4
    3c5c:	0115      	lsls	r5, r2, #4
    3c5e:	0118      	lsls	r0, r3, #4
    3c60:	488c      	ldr	r0, [pc, #560]	@ (3e94 <get_ip_port@@Base+0x145c>)
    3c62:	4478      	add	r0, pc
    3c64:	4770      	bx	lr
    3c66:	f5a1 7080 	sub.w	r0, r1, #256	@ 0x100
    3c6a:	281f      	cmp	r0, #31
    3c6c:	d824      	bhi.n	3cb8 <get_ip_port@@Base+0x1280>
    3c6e:	e8df f010 	tbh	[pc, r0, lsl #1]
    3c72:	0020      	movs	r0, r4
    3c74:	00b0      	lsls	r0, r6, #2
    3c76:	00b3      	lsls	r3, r6, #2
    3c78:	00b6      	lsls	r6, r6, #2
    3c7a:	00b9      	lsls	r1, r7, #2
    3c7c:	00bc      	lsls	r4, r7, #2
    3c7e:	00bf      	lsls	r7, r7, #2
    3c80:	00c2      	lsls	r2, r0, #3
    3c82:	00c5      	lsls	r5, r0, #3
    3c84:	00c8      	lsls	r0, r1, #3
    3c86:	00cb      	lsls	r3, r1, #3
    3c88:	00ce      	lsls	r6, r1, #3
    3c8a:	00d1      	lsls	r1, r2, #3
    3c8c:	00d4      	lsls	r4, r2, #3
    3c8e:	00d7      	lsls	r7, r2, #3
    3c90:	00da      	lsls	r2, r3, #3
    3c92:	00dd      	lsls	r5, r3, #3
    3c94:	00e0      	lsls	r0, r4, #3
    3c96:	00e3      	lsls	r3, r4, #3
    3c98:	00e6      	lsls	r6, r4, #3
    3c9a:	00e9      	lsls	r1, r5, #3
    3c9c:	00ec      	lsls	r4, r5, #3
    3c9e:	00ef      	lsls	r7, r5, #3
    3ca0:	00f2      	lsls	r2, r6, #3
    3ca2:	00f5      	lsls	r5, r6, #3
    3ca4:	00f8      	lsls	r0, r7, #3
    3ca6:	00fb      	lsls	r3, r7, #3
    3ca8:	00fe      	lsls	r6, r7, #3
    3caa:	0103      	lsls	r3, r0, #4
    3cac:	0106      	lsls	r6, r0, #4
    3cae:	0109      	lsls	r1, r1, #4
    3cb0:	010c      	lsls	r4, r1, #4
    3cb2:	48a6      	ldr	r0, [pc, #664]	@ (3f4c <get_ip_port@@Base+0x1514>)
    3cb4:	4478      	add	r0, pc
    3cb6:	4770      	bx	lr
    3cb8:	48c4      	ldr	r0, [pc, #784]	@ (3fcc <get_ip_port@@Base+0x1594>)
    3cba:	4478      	add	r0, pc
    3cbc:	4770      	bx	lr
    3cbe:	4876      	ldr	r0, [pc, #472]	@ (3e98 <get_ip_port@@Base+0x1460>)
    3cc0:	4478      	add	r0, pc
    3cc2:	4770      	bx	lr
    3cc4:	4875      	ldr	r0, [pc, #468]	@ (3e9c <get_ip_port@@Base+0x1464>)
    3cc6:	4478      	add	r0, pc
    3cc8:	4770      	bx	lr
    3cca:	4875      	ldr	r0, [pc, #468]	@ (3ea0 <get_ip_port@@Base+0x1468>)
    3ccc:	4478      	add	r0, pc
    3cce:	4770      	bx	lr
    3cd0:	4874      	ldr	r0, [pc, #464]	@ (3ea4 <get_ip_port@@Base+0x146c>)
    3cd2:	4478      	add	r0, pc
    3cd4:	4770      	bx	lr
    3cd6:	4874      	ldr	r0, [pc, #464]	@ (3ea8 <get_ip_port@@Base+0x1470>)
    3cd8:	4478      	add	r0, pc
    3cda:	4770      	bx	lr
    3cdc:	4873      	ldr	r0, [pc, #460]	@ (3eac <get_ip_port@@Base+0x1474>)
    3cde:	4478      	add	r0, pc
    3ce0:	4770      	bx	lr
    3ce2:	4873      	ldr	r0, [pc, #460]	@ (3eb0 <get_ip_port@@Base+0x1478>)
    3ce4:	4478      	add	r0, pc
    3ce6:	4770      	bx	lr
    3ce8:	4872      	ldr	r0, [pc, #456]	@ (3eb4 <get_ip_port@@Base+0x147c>)
    3cea:	4478      	add	r0, pc
    3cec:	4770      	bx	lr
    3cee:	4872      	ldr	r0, [pc, #456]	@ (3eb8 <get_ip_port@@Base+0x1480>)
    3cf0:	4478      	add	r0, pc
    3cf2:	4770      	bx	lr
    3cf4:	4871      	ldr	r0, [pc, #452]	@ (3ebc <get_ip_port@@Base+0x1484>)
    3cf6:	4478      	add	r0, pc
    3cf8:	4770      	bx	lr
    3cfa:	4871      	ldr	r0, [pc, #452]	@ (3ec0 <get_ip_port@@Base+0x1488>)
    3cfc:	4478      	add	r0, pc
    3cfe:	4770      	bx	lr
    3d00:	4870      	ldr	r0, [pc, #448]	@ (3ec4 <get_ip_port@@Base+0x148c>)
    3d02:	4478      	add	r0, pc
    3d04:	4770      	bx	lr
    3d06:	4870      	ldr	r0, [pc, #448]	@ (3ec8 <get_ip_port@@Base+0x1490>)
    3d08:	4478      	add	r0, pc
    3d0a:	4770      	bx	lr
    3d0c:	4860      	ldr	r0, [pc, #384]	@ (3e90 <get_ip_port@@Base+0x1458>)
    3d0e:	4478      	add	r0, pc
    3d10:	4770      	bx	lr
    3d12:	486e      	ldr	r0, [pc, #440]	@ (3ecc <get_ip_port@@Base+0x1494>)
    3d14:	4478      	add	r0, pc
    3d16:	4770      	bx	lr
    3d18:	486d      	ldr	r0, [pc, #436]	@ (3ed0 <get_ip_port@@Base+0x1498>)
    3d1a:	4478      	add	r0, pc
    3d1c:	4770      	bx	lr
    3d1e:	486d      	ldr	r0, [pc, #436]	@ (3ed4 <get_ip_port@@Base+0x149c>)
    3d20:	4478      	add	r0, pc
    3d22:	4770      	bx	lr
    3d24:	486c      	ldr	r0, [pc, #432]	@ (3ed8 <get_ip_port@@Base+0x14a0>)
    3d26:	4478      	add	r0, pc
    3d28:	4770      	bx	lr
    3d2a:	486c      	ldr	r0, [pc, #432]	@ (3edc <get_ip_port@@Base+0x14a4>)
    3d2c:	4478      	add	r0, pc
    3d2e:	4770      	bx	lr
    3d30:	486b      	ldr	r0, [pc, #428]	@ (3ee0 <get_ip_port@@Base+0x14a8>)
    3d32:	4478      	add	r0, pc
    3d34:	4770      	bx	lr
    3d36:	486b      	ldr	r0, [pc, #428]	@ (3ee4 <get_ip_port@@Base+0x14ac>)
    3d38:	4478      	add	r0, pc
    3d3a:	4770      	bx	lr
    3d3c:	486a      	ldr	r0, [pc, #424]	@ (3ee8 <get_ip_port@@Base+0x14b0>)
    3d3e:	4478      	add	r0, pc
    3d40:	4770      	bx	lr
    3d42:	486a      	ldr	r0, [pc, #424]	@ (3eec <get_ip_port@@Base+0x14b4>)
    3d44:	4478      	add	r0, pc
    3d46:	4770      	bx	lr
    3d48:	4869      	ldr	r0, [pc, #420]	@ (3ef0 <get_ip_port@@Base+0x14b8>)
    3d4a:	4478      	add	r0, pc
    3d4c:	4770      	bx	lr
    3d4e:	4869      	ldr	r0, [pc, #420]	@ (3ef4 <get_ip_port@@Base+0x14bc>)
    3d50:	4478      	add	r0, pc
    3d52:	4770      	bx	lr
    3d54:	4868      	ldr	r0, [pc, #416]	@ (3ef8 <get_ip_port@@Base+0x14c0>)
    3d56:	4478      	add	r0, pc
    3d58:	4770      	bx	lr
    3d5a:	4868      	ldr	r0, [pc, #416]	@ (3efc <get_ip_port@@Base+0x14c4>)
    3d5c:	4478      	add	r0, pc
    3d5e:	4770      	bx	lr
    3d60:	4867      	ldr	r0, [pc, #412]	@ (3f00 <get_ip_port@@Base+0x14c8>)
    3d62:	4478      	add	r0, pc
    3d64:	4770      	bx	lr
    3d66:	4867      	ldr	r0, [pc, #412]	@ (3f04 <get_ip_port@@Base+0x14cc>)
    3d68:	4478      	add	r0, pc
    3d6a:	4770      	bx	lr
    3d6c:	4866      	ldr	r0, [pc, #408]	@ (3f08 <get_ip_port@@Base+0x14d0>)
    3d6e:	4478      	add	r0, pc
    3d70:	4770      	bx	lr
    3d72:	4866      	ldr	r0, [pc, #408]	@ (3f0c <get_ip_port@@Base+0x14d4>)
    3d74:	4478      	add	r0, pc
    3d76:	4770      	bx	lr
    3d78:	4865      	ldr	r0, [pc, #404]	@ (3f10 <get_ip_port@@Base+0x14d8>)
    3d7a:	4478      	add	r0, pc
    3d7c:	4770      	bx	lr
    3d7e:	4865      	ldr	r0, [pc, #404]	@ (3f14 <get_ip_port@@Base+0x14dc>)
    3d80:	4478      	add	r0, pc
    3d82:	4770      	bx	lr
    3d84:	4864      	ldr	r0, [pc, #400]	@ (3f18 <get_ip_port@@Base+0x14e0>)
    3d86:	4478      	add	r0, pc
    3d88:	4770      	bx	lr
    3d8a:	4864      	ldr	r0, [pc, #400]	@ (3f1c <get_ip_port@@Base+0x14e4>)
    3d8c:	4478      	add	r0, pc
    3d8e:	4770      	bx	lr
    3d90:	4863      	ldr	r0, [pc, #396]	@ (3f20 <get_ip_port@@Base+0x14e8>)
    3d92:	4478      	add	r0, pc
    3d94:	4770      	bx	lr
    3d96:	4863      	ldr	r0, [pc, #396]	@ (3f24 <get_ip_port@@Base+0x14ec>)
    3d98:	4478      	add	r0, pc
    3d9a:	4770      	bx	lr
    3d9c:	4862      	ldr	r0, [pc, #392]	@ (3f28 <get_ip_port@@Base+0x14f0>)
    3d9e:	4478      	add	r0, pc
    3da0:	4770      	bx	lr
    3da2:	4862      	ldr	r0, [pc, #392]	@ (3f2c <get_ip_port@@Base+0x14f4>)
    3da4:	4478      	add	r0, pc
    3da6:	4770      	bx	lr
    3da8:	4861      	ldr	r0, [pc, #388]	@ (3f30 <get_ip_port@@Base+0x14f8>)
    3daa:	4478      	add	r0, pc
    3dac:	4770      	bx	lr
    3dae:	4861      	ldr	r0, [pc, #388]	@ (3f34 <get_ip_port@@Base+0x14fc>)
    3db0:	4478      	add	r0, pc
    3db2:	4770      	bx	lr
    3db4:	4860      	ldr	r0, [pc, #384]	@ (3f38 <get_ip_port@@Base+0x1500>)
    3db6:	4478      	add	r0, pc
    3db8:	4770      	bx	lr
    3dba:	4860      	ldr	r0, [pc, #384]	@ (3f3c <get_ip_port@@Base+0x1504>)
    3dbc:	4478      	add	r0, pc
    3dbe:	4770      	bx	lr
    3dc0:	485f      	ldr	r0, [pc, #380]	@ (3f40 <get_ip_port@@Base+0x1508>)
    3dc2:	4478      	add	r0, pc
    3dc4:	4770      	bx	lr
    3dc6:	485f      	ldr	r0, [pc, #380]	@ (3f44 <get_ip_port@@Base+0x150c>)
    3dc8:	4478      	add	r0, pc
    3dca:	4770      	bx	lr
    3dcc:	485e      	ldr	r0, [pc, #376]	@ (3f48 <get_ip_port@@Base+0x1510>)
    3dce:	4478      	add	r0, pc
    3dd0:	4770      	bx	lr
    3dd2:	485f      	ldr	r0, [pc, #380]	@ (3f50 <get_ip_port@@Base+0x1518>)
    3dd4:	4478      	add	r0, pc
    3dd6:	4770      	bx	lr
    3dd8:	485e      	ldr	r0, [pc, #376]	@ (3f54 <get_ip_port@@Base+0x151c>)
    3dda:	4478      	add	r0, pc
    3ddc:	4770      	bx	lr
    3dde:	485e      	ldr	r0, [pc, #376]	@ (3f58 <get_ip_port@@Base+0x1520>)
    3de0:	4478      	add	r0, pc
    3de2:	4770      	bx	lr
    3de4:	485d      	ldr	r0, [pc, #372]	@ (3f5c <get_ip_port@@Base+0x1524>)
    3de6:	4478      	add	r0, pc
    3de8:	4770      	bx	lr
    3dea:	485d      	ldr	r0, [pc, #372]	@ (3f60 <get_ip_port@@Base+0x1528>)
    3dec:	4478      	add	r0, pc
    3dee:	4770      	bx	lr
    3df0:	485c      	ldr	r0, [pc, #368]	@ (3f64 <get_ip_port@@Base+0x152c>)
    3df2:	4478      	add	r0, pc
    3df4:	4770      	bx	lr
    3df6:	485c      	ldr	r0, [pc, #368]	@ (3f68 <get_ip_port@@Base+0x1530>)
    3df8:	4478      	add	r0, pc
    3dfa:	4770      	bx	lr
    3dfc:	485b      	ldr	r0, [pc, #364]	@ (3f6c <get_ip_port@@Base+0x1534>)
    3dfe:	4478      	add	r0, pc
    3e00:	4770      	bx	lr
    3e02:	485b      	ldr	r0, [pc, #364]	@ (3f70 <get_ip_port@@Base+0x1538>)
    3e04:	4478      	add	r0, pc
    3e06:	4770      	bx	lr
    3e08:	485a      	ldr	r0, [pc, #360]	@ (3f74 <get_ip_port@@Base+0x153c>)
    3e0a:	4478      	add	r0, pc
    3e0c:	4770      	bx	lr
    3e0e:	485a      	ldr	r0, [pc, #360]	@ (3f78 <get_ip_port@@Base+0x1540>)
    3e10:	4478      	add	r0, pc
    3e12:	4770      	bx	lr
    3e14:	4859      	ldr	r0, [pc, #356]	@ (3f7c <get_ip_port@@Base+0x1544>)
    3e16:	4478      	add	r0, pc
    3e18:	4770      	bx	lr
    3e1a:	4859      	ldr	r0, [pc, #356]	@ (3f80 <get_ip_port@@Base+0x1548>)
    3e1c:	4478      	add	r0, pc
    3e1e:	4770      	bx	lr
    3e20:	4858      	ldr	r0, [pc, #352]	@ (3f84 <get_ip_port@@Base+0x154c>)
    3e22:	4478      	add	r0, pc
    3e24:	4770      	bx	lr
    3e26:	4858      	ldr	r0, [pc, #352]	@ (3f88 <get_ip_port@@Base+0x1550>)
    3e28:	4478      	add	r0, pc
    3e2a:	4770      	bx	lr
    3e2c:	4857      	ldr	r0, [pc, #348]	@ (3f8c <get_ip_port@@Base+0x1554>)
    3e2e:	4478      	add	r0, pc
    3e30:	4770      	bx	lr
    3e32:	4857      	ldr	r0, [pc, #348]	@ (3f90 <get_ip_port@@Base+0x1558>)
    3e34:	4478      	add	r0, pc
    3e36:	4770      	bx	lr
    3e38:	4856      	ldr	r0, [pc, #344]	@ (3f94 <get_ip_port@@Base+0x155c>)
    3e3a:	4478      	add	r0, pc
    3e3c:	4770      	bx	lr
    3e3e:	4856      	ldr	r0, [pc, #344]	@ (3f98 <get_ip_port@@Base+0x1560>)
    3e40:	4478      	add	r0, pc
    3e42:	4770      	bx	lr
    3e44:	4855      	ldr	r0, [pc, #340]	@ (3f9c <get_ip_port@@Base+0x1564>)
    3e46:	4478      	add	r0, pc
    3e48:	4770      	bx	lr
    3e4a:	4855      	ldr	r0, [pc, #340]	@ (3fa0 <get_ip_port@@Base+0x1568>)
    3e4c:	4478      	add	r0, pc
    3e4e:	4770      	bx	lr
    3e50:	4854      	ldr	r0, [pc, #336]	@ (3fa4 <get_ip_port@@Base+0x156c>)
    3e52:	4478      	add	r0, pc
    3e54:	4770      	bx	lr
    3e56:	4854      	ldr	r0, [pc, #336]	@ (3fa8 <get_ip_port@@Base+0x1570>)
    3e58:	4478      	add	r0, pc
    3e5a:	4770      	bx	lr
    3e5c:	4853      	ldr	r0, [pc, #332]	@ (3fac <get_ip_port@@Base+0x1574>)
    3e5e:	4478      	add	r0, pc
    3e60:	4770      	bx	lr
    3e62:	4853      	ldr	r0, [pc, #332]	@ (3fb0 <get_ip_port@@Base+0x1578>)
    3e64:	4478      	add	r0, pc
    3e66:	4770      	bx	lr
    3e68:	4852      	ldr	r0, [pc, #328]	@ (3fb4 <get_ip_port@@Base+0x157c>)
    3e6a:	4478      	add	r0, pc
    3e6c:	4770      	bx	lr
    3e6e:	4852      	ldr	r0, [pc, #328]	@ (3fb8 <get_ip_port@@Base+0x1580>)
    3e70:	4478      	add	r0, pc
    3e72:	4770      	bx	lr
    3e74:	0f50      	lsrs	r0, r2, #29
    3e76:	0000      	movs	r0, r0
    3e78:	4850      	ldr	r0, [pc, #320]	@ (3fbc <get_ip_port@@Base+0x1584>)
    3e7a:	4478      	add	r0, pc
    3e7c:	4770      	bx	lr
    3e7e:	4850      	ldr	r0, [pc, #320]	@ (3fc0 <get_ip_port@@Base+0x1588>)
    3e80:	4478      	add	r0, pc
    3e82:	4770      	bx	lr
    3e84:	484f      	ldr	r0, [pc, #316]	@ (3fc4 <get_ip_port@@Base+0x158c>)
    3e86:	4478      	add	r0, pc
    3e88:	4770      	bx	lr
    3e8a:	484f      	ldr	r0, [pc, #316]	@ (3fc8 <get_ip_port@@Base+0x1590>)
    3e8c:	4478      	add	r0, pc
    3e8e:	4770      	bx	lr
    3e90:	0ddb      	lsrs	r3, r3, #23
    3e92:	0000      	movs	r0, r0
    3e94:	0e8a      	lsrs	r2, r1, #26
    3e96:	0000      	movs	r0, r0
    3e98:	0e2f      	lsrs	r7, r5, #24
    3e9a:	0000      	movs	r0, r0
    3e9c:	0e2c      	lsrs	r4, r5, #24
    3e9e:	0000      	movs	r0, r0
    3ea0:	0e29      	lsrs	r1, r5, #24
    3ea2:	0000      	movs	r0, r0
    3ea4:	0e26      	lsrs	r6, r4, #24
    3ea6:	0000      	movs	r0, r0
    3ea8:	0e23      	lsrs	r3, r4, #24
    3eaa:	0000      	movs	r0, r0
    3eac:	0e20      	lsrs	r0, r4, #24
    3eae:	0000      	movs	r0, r0
    3eb0:	0e1d      	lsrs	r5, r3, #24
    3eb2:	0000      	movs	r0, r0
    3eb4:	0e1a      	lsrs	r2, r3, #24
    3eb6:	0000      	movs	r0, r0
    3eb8:	0e17      	lsrs	r7, r2, #24
    3eba:	0000      	movs	r0, r0
    3ebc:	0e14      	lsrs	r4, r2, #24
    3ebe:	0000      	movs	r0, r0
    3ec0:	0e11      	lsrs	r1, r2, #24
    3ec2:	0000      	movs	r0, r0
    3ec4:	0e0f      	lsrs	r7, r1, #24
    3ec6:	0000      	movs	r0, r0
    3ec8:	0e0d      	lsrs	r5, r1, #24
    3eca:	0000      	movs	r0, r0
    3ecc:	0e05      	lsrs	r5, r0, #24
    3ece:	0000      	movs	r0, r0
    3ed0:	0e02      	lsrs	r2, r0, #24
    3ed2:	0000      	movs	r0, r0
    3ed4:	0dff      	lsrs	r7, r7, #23
    3ed6:	0000      	movs	r0, r0
    3ed8:	0dfc      	lsrs	r4, r7, #23
    3eda:	0000      	movs	r0, r0
    3edc:	0df9      	lsrs	r1, r7, #23
    3ede:	0000      	movs	r0, r0
    3ee0:	0df6      	lsrs	r6, r6, #23
    3ee2:	0000      	movs	r0, r0
    3ee4:	0df3      	lsrs	r3, r6, #23
    3ee6:	0000      	movs	r0, r0
    3ee8:	0df0      	lsrs	r0, r6, #23
    3eea:	0000      	movs	r0, r0
    3eec:	0ded      	lsrs	r5, r5, #23
    3eee:	0000      	movs	r0, r0
    3ef0:	0dea      	lsrs	r2, r5, #23
    3ef2:	0000      	movs	r0, r0
    3ef4:	0de7      	lsrs	r7, r4, #23
    3ef6:	0000      	movs	r0, r0
    3ef8:	0de5      	lsrs	r5, r4, #23
    3efa:	0000      	movs	r0, r0
    3efc:	0de3      	lsrs	r3, r4, #23
    3efe:	0000      	movs	r0, r0
    3f00:	0de1      	lsrs	r1, r4, #23
    3f02:	0000      	movs	r0, r0
    3f04:	0ddf      	lsrs	r7, r3, #23
    3f06:	0000      	movs	r0, r0
    3f08:	0ddd      	lsrs	r5, r3, #23
    3f0a:	0000      	movs	r0, r0
    3f0c:	0ddb      	lsrs	r3, r3, #23
    3f0e:	0000      	movs	r0, r0
    3f10:	0dd9      	lsrs	r1, r3, #23
    3f12:	0000      	movs	r0, r0
    3f14:	0dd7      	lsrs	r7, r2, #23
    3f16:	0000      	movs	r0, r0
    3f18:	0dd5      	lsrs	r5, r2, #23
    3f1a:	0000      	movs	r0, r0
    3f1c:	0dd3      	lsrs	r3, r2, #23
    3f1e:	0000      	movs	r0, r0
    3f20:	0dd1      	lsrs	r1, r2, #23
    3f22:	0000      	movs	r0, r0
    3f24:	0dcf      	lsrs	r7, r1, #23
    3f26:	0000      	movs	r0, r0
    3f28:	0dcd      	lsrs	r5, r1, #23
    3f2a:	0000      	movs	r0, r0
    3f2c:	0dcb      	lsrs	r3, r1, #23
    3f2e:	0000      	movs	r0, r0
    3f30:	0dc9      	lsrs	r1, r1, #23
    3f32:	0000      	movs	r0, r0
    3f34:	0dc7      	lsrs	r7, r0, #23
    3f36:	0000      	movs	r0, r0
    3f38:	0dc5      	lsrs	r5, r0, #23
    3f3a:	0000      	movs	r0, r0
    3f3c:	0dc3      	lsrs	r3, r0, #23
    3f3e:	0000      	movs	r0, r0
    3f40:	0dc1      	lsrs	r1, r0, #23
    3f42:	0000      	movs	r0, r0
    3f44:	0dbf      	lsrs	r7, r7, #22
    3f46:	0000      	movs	r0, r0
    3f48:	0dbd      	lsrs	r5, r7, #22
    3f4a:	0000      	movs	r0, r0
    3f4c:	0edb      	lsrs	r3, r3, #27
    3f4e:	0000      	movs	r0, r0
    3f50:	0dbe      	lsrs	r6, r7, #22
    3f52:	0000      	movs	r0, r0
    3f54:	0dbb      	lsrs	r3, r7, #22
    3f56:	0000      	movs	r0, r0
    3f58:	0db8      	lsrs	r0, r7, #22
    3f5a:	0000      	movs	r0, r0
    3f5c:	0db5      	lsrs	r5, r6, #22
    3f5e:	0000      	movs	r0, r0
    3f60:	0db2      	lsrs	r2, r6, #22
    3f62:	0000      	movs	r0, r0
    3f64:	0daf      	lsrs	r7, r5, #22
    3f66:	0000      	movs	r0, r0
    3f68:	0dac      	lsrs	r4, r5, #22
    3f6a:	0000      	movs	r0, r0
    3f6c:	0da9      	lsrs	r1, r5, #22
    3f6e:	0000      	movs	r0, r0
    3f70:	0da6      	lsrs	r6, r4, #22
    3f72:	0000      	movs	r0, r0
    3f74:	0da3      	lsrs	r3, r4, #22
    3f76:	0000      	movs	r0, r0
    3f78:	0da1      	lsrs	r1, r4, #22
    3f7a:	0000      	movs	r0, r0
    3f7c:	0d9f      	lsrs	r7, r3, #22
    3f7e:	0000      	movs	r0, r0
    3f80:	0d9d      	lsrs	r5, r3, #22
    3f82:	0000      	movs	r0, r0
    3f84:	0d9b      	lsrs	r3, r3, #22
    3f86:	0000      	movs	r0, r0
    3f88:	0d99      	lsrs	r1, r3, #22
    3f8a:	0000      	movs	r0, r0
    3f8c:	0d97      	lsrs	r7, r2, #22
    3f8e:	0000      	movs	r0, r0
    3f90:	0d95      	lsrs	r5, r2, #22
    3f92:	0000      	movs	r0, r0
    3f94:	0d93      	lsrs	r3, r2, #22
    3f96:	0000      	movs	r0, r0
    3f98:	0d91      	lsrs	r1, r2, #22
    3f9a:	0000      	movs	r0, r0
    3f9c:	0d8f      	lsrs	r7, r1, #22
    3f9e:	0000      	movs	r0, r0
    3fa0:	0d8d      	lsrs	r5, r1, #22
    3fa2:	0000      	movs	r0, r0
    3fa4:	0d8b      	lsrs	r3, r1, #22
    3fa6:	0000      	movs	r0, r0
    3fa8:	0d89      	lsrs	r1, r1, #22
    3faa:	0000      	movs	r0, r0
    3fac:	0d87      	lsrs	r7, r0, #22
    3fae:	0000      	movs	r0, r0
    3fb0:	0d85      	lsrs	r5, r0, #22
    3fb2:	0000      	movs	r0, r0
    3fb4:	0d83      	lsrs	r3, r0, #22
    3fb6:	0000      	movs	r0, r0
    3fb8:	0d81      	lsrs	r1, r0, #22
    3fba:	0000      	movs	r0, r0
    3fbc:	0d7b      	lsrs	r3, r7, #21
    3fbe:	0000      	movs	r0, r0
    3fc0:	0d79      	lsrs	r1, r7, #21
    3fc2:	0000      	movs	r0, r0
    3fc4:	0d77      	lsrs	r7, r6, #21
    3fc6:	0000      	movs	r0, r0
    3fc8:	0d75      	lsrs	r5, r6, #21
    3fca:	0000      	movs	r0, r0
    3fcc:	0f4b      	lsrs	r3, r1, #29
    3fce:	0000      	movs	r0, r0
    3fd0:	e000      	b.n	3fd4 <get_ip_port@@Base+0x159c>
    3fd2:	e1a0      	b.n	4316 <get_ip_port@@Base+0x18de>
    3fd4:	1fff      	subs	r7, r7, #7
    3fd6:	e89e d034 	ldmia.w	lr, {r2, r4, r5, ip, lr, pc}
    3fda:	e59e      	b.n	3b1a <get_ip_port@@Base+0x10e2>
    3fdc:	e03c      	b.n	4058 <get_ip_port@@Base+0x1620>
    3fde:	e59e      	b.n	3b1e <get_ip_port@@Base+0x10e6>
    3fe0:	ff1e e12f 	vrhadd.u16	d14, d14, d31
    3fe4:	0b20      	lsrs	r0, r4, #12
    3fe6:	ec90 ff1e 	ldc	15, cr15, [r0], {30}
    3fea:	e12f      	b.n	424c <get_ip_port@@Base+0x1814>
    3fec:	0b20      	lsrs	r0, r4, #12
    3fee:	ec90 ff1e 	ldc	15, cr15, [r0], {30}
    3ff2:	e12f      	b.n	4254 <get_ip_port@@Base+0x181c>
    3ff4:	0b20      	lsrs	r0, r4, #12
    3ff6:	ecd0 ff1e 	ldcl	15, cr15, [r0], {30}
    3ffa:	e12f      	b.n	425c <get_ip_port@@Base+0x1824>
    3ffc:	2900      	cmp	r1, #0
    3ffe:	d056      	beq.n	40ae <get_ip_port@@Base+0x1676>
    4000:	ea80 0c01 	eor.w	ip, r0, r1
    4004:	bf48      	it	mi
    4006:	4249      	negmi	r1, r1
    4008:	1e4a      	subs	r2, r1, #1
    400a:	d038      	beq.n	407e <get_ip_port@@Base+0x1646>
    400c:	0003      	movs	r3, r0
    400e:	bf48      	it	mi
    4010:	4243      	negmi	r3, r0
    4012:	428b      	cmp	r3, r1
    4014:	d938      	bls.n	4088 <get_ip_port@@Base+0x1650>
    4016:	4211      	tst	r1, r2
    4018:	d03e      	beq.n	4098 <get_ip_port@@Base+0x1660>
    401a:	fab1 f281 	clz	r2, r1
    401e:	fab3 f083 	clz	r0, r3
    4022:	eba2 0000 	sub.w	r0, r2, r0
    4026:	f04f 0201 	mov.w	r2, #1
    402a:	fa01 f100 	lsl.w	r1, r1, r0
    402e:	fa02 f200 	lsl.w	r2, r2, r0
    4032:	f04f 0000 	mov.w	r0, #0
    4036:	428b      	cmp	r3, r1
    4038:	bf24      	itt	cs
    403a:	1a5b      	subcs	r3, r3, r1
    403c:	4310      	orrcs	r0, r2
    403e:	ebb3 0f51 	cmp.w	r3, r1, lsr #1
    4042:	bf24      	itt	cs
    4044:	eba3 0351 	subcs.w	r3, r3, r1, lsr #1
    4048:	ea40 0052 	orrcs.w	r0, r0, r2, lsr #1
    404c:	ebb3 0f91 	cmp.w	r3, r1, lsr #2
    4050:	bf24      	itt	cs
    4052:	eba3 0391 	subcs.w	r3, r3, r1, lsr #2
    4056:	ea40 0092 	orrcs.w	r0, r0, r2, lsr #2
    405a:	ebb3 0fd1 	cmp.w	r3, r1, lsr #3
    405e:	bf24      	itt	cs
    4060:	eba3 03d1 	subcs.w	r3, r3, r1, lsr #3
    4064:	ea40 00d2 	orrcs.w	r0, r0, r2, lsr #3
    4068:	2b00      	cmp	r3, #0
    406a:	bf1c      	itt	ne
    406c:	ea5f 1212 	movsne.w	r2, r2, lsr #4
    4070:	0909      	lsrne	r1, r1, #4
    4072:	d1e0      	bne.n	4036 <get_ip_port@@Base+0x15fe>
    4074:	f1bc 0f00 	cmp.w	ip, #0
    4078:	bf48      	it	mi
    407a:	4240      	negmi	r0, r0
    407c:	4770      	bx	lr
    407e:	ea9c 0f00 	teq	ip, r0
    4082:	bf48      	it	mi
    4084:	4240      	negmi	r0, r0
    4086:	4770      	bx	lr
    4088:	bf38      	it	cc
    408a:	2000      	movcc	r0, #0
    408c:	bf04      	itt	eq
    408e:	ea4f 70ec 	moveq.w	r0, ip, asr #31
    4092:	f040 0001 	orreq.w	r0, r0, #1
    4096:	4770      	bx	lr
    4098:	fab1 f281 	clz	r2, r1
    409c:	f1c2 021f 	rsb	r2, r2, #31
    40a0:	f1bc 0f00 	cmp.w	ip, #0
    40a4:	fa23 f002 	lsr.w	r0, r3, r2
    40a8:	bf48      	it	mi
    40aa:	4240      	negmi	r0, r0
    40ac:	4770      	bx	lr
    40ae:	2800      	cmp	r0, #0
    40b0:	bfc8      	it	gt
    40b2:	f06f 4000 	mvngt.w	r0, #2147483648	@ 0x80000000
    40b6:	bfb8      	it	lt
    40b8:	f04f 4000 	movlt.w	r0, #2147483648	@ 0x80000000
    40bc:	f000 b80e 	b.w	40dc <get_ip_port@@Base+0x16a4>
    40c0:	2900      	cmp	r1, #0
    40c2:	d0f4      	beq.n	40ae <get_ip_port@@Base+0x1676>
    40c4:	e92d 4003 	stmdb	sp!, {r0, r1, lr}
    40c8:	f7ff ff9a 	bl	4000 <get_ip_port@@Base+0x15c8>
    40cc:	e8bd 4006 	ldmia.w	sp!, {r1, r2, lr}
    40d0:	fb02 f300 	mul.w	r3, r2, r0
    40d4:	eba1 0103 	sub.w	r1, r1, r3
    40d8:	4770      	bx	lr
    40da:	bf00      	nop
    40dc:	b502      	push	{r1, lr}
    40de:	f04f 0008 	mov.w	r0, #8
    40e2:	f7fd ea5e 	blx	15a0 <raise@plt>
    40e6:	bd02      	pop	{r1, pc}
    40e8:	4778      	bx	pc
    40ea:	46c0      	nop			@ (mov r8, r8)
    40ec:	c000      	stmia	r0!, {}
    40ee:	e59f      	b.n	3c30 <get_ip_port@@Base+0x11f8>
    40f0:	f00f e08c 	blx	41320c <_end@@Base+0x40c1f4>
    40f4:	d2ec      	bcs.n	40d0 <get_ip_port@@Base+0x1698>
    40f6:	ffff 4778 	vqshl.u32	q10, q12, #31
    40fa:	46c0      	nop			@ (mov r8, r8)
    40fc:	c000      	stmia	r0!, {}
    40fe:	e59f      	b.n	3c40 <get_ip_port@@Base+0x1208>
    4100:	f00f e08c 	blx	41321c <_end@@Base+0x40c204>
    4104:	d414      	bmi.n	4130 <get_ip_port@@Base+0x16f8>
    4106:	ffff 4778 	vqshl.u32	q10, q12, #31
    410a:	46c0      	nop			@ (mov r8, r8)
    410c:	c000      	stmia	r0!, {}
    410e:	e59f      	b.n	3c50 <get_ip_port@@Base+0x1218>
    4110:	f00f e08c 	blx	41322c <_end@@Base+0x40c214>
    4114:	d428      	bmi.n	4168 <get_ip_port@@Base+0x1730>
    4116:	ffff 4778 	vqshl.u32	q10, q12, #31
    411a:	46c0      	nop			@ (mov r8, r8)
    411c:	c000      	stmia	r0!, {}
    411e:	e59f      	b.n	3c60 <get_ip_port@@Base+0x1228>
    4120:	f00f e08c 	blx	41323c <_end@@Base+0x40c224>
    4124:	d400      	bmi.n	4128 <get_ip_port@@Base+0x16f0>
    4126:	ffff 4778 	vqshl.u32	q10, q12, #31
    412a:	46c0      	nop			@ (mov r8, r8)
    412c:	c000      	stmia	r0!, {}
    412e:	e59f      	b.n	3c70 <get_ip_port@@Base+0x1238>
    4130:	f00f e08c 	blx	41324c <_end@@Base+0x40c234>
    4134:	fe98 ffff 	mrc2	15, 4, pc, cr8, cr15, {7}
    4138:	4778      	bx	pc
    413a:	46c0      	nop			@ (mov r8, r8)
    413c:	c000      	stmia	r0!, {}
    413e:	e59f      	b.n	3c80 <get_ip_port@@Base+0x1248>
    4140:	f00f e08c 	blx	41325c <_end@@Base+0x40c244>
    4144:	feac ffff 	mcr2	15, 5, pc, cr12, cr15, {7}	@ <UNPREDICTABLE>
