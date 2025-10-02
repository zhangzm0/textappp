package com.example.application;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public class FirstFragment extends Fragment {

    private RecyclerView recyclerView;
    private CustomAdapter adapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_first, container, false);

        recyclerView = view.findViewById(R.id.recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        List<String> data = new ArrayList<>();
        data.add("短项目");
        data.add("这是一个非常长的项目，它的内容会超出屏幕的显示范围，需要滚动才能查看完整内容。" +
				 "这是为了测试RecyclerView在包含长内容时的滚动行为。长文本应该能够正确显示并且用户可以滚动查看完整内容。" +
				 "这是另一行文本，用于增加长度。继续添加更多文本以确保它确实超出屏幕范围。" +
				 "再多一些内容，这样我们就可以确保滚动功能正常工作。");

        adapter = new CustomAdapter(data);
        recyclerView.setAdapter(adapter);

        return view;
    }
}

