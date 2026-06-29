package com.lamthoncoding.myfschoolse1913be.service;

import com.lamthoncoding.myfschoolse1913be.payload.response.EventResponse;

import java.util.List;

public interface EventService {

    List<EventResponse> getAllEvents();

    List<EventResponse> getEventsForTeacher();

    List<EventResponse> getEventsForStudent();
}
